Unit Crt01;
  Interface
    Uses crt,Dos;
    Type
      Str2=String[2];
      Scr=Record
        ekr:Array [1..4000] of byte;
      End;
      CharSet  = Set of Char;
      EditType = Record
          Data       :String;
          x,y        :Byte;  { Koordinatlar }
          len1,len2  :Byte;  { Len1 ekranda gorunen , Len2 gercek str uzunlugu}
          Tc,Bc      :Byte;  { renkleri }
          Cnt        :Byte;  { Kontrol Byte
                                Cnt : Exitcode
                                1   : Ok, Enter ile cikildi.
                                2   : ESC ile cikildi.
                                4   : Up Arrow
                                8   : Down Arrow;
                               16   : s='' iken cikis}
          Tip        :Byte;
      End;

    Var
      k:Scr;
      F:File of scr;
      ox,oy,oattr:Byte;
      Screens:Array [1..6] of scr;
      Edits:Array [1..50] of EditType;
    Const
     Black        = 0;
     Blue         = 1;
     Green        = 2;
     Cyan         = 3;
     Red          = 4;
     Magenta      = 5;
     Brown        = 6;
     LightGray    = 7;
     DarkGray     = 8;
     LightBlue    = 9;
     LightGreen   =10;
     LightCyan    =11;
     LightRed     =12;
     LightMagenta =13;
     Yellow       =14;
     White        =15;
     Enter        =1;
     Esc          =2;
     UpArrow      =4;
     DownArrow    =8;


  Printable : CharSet = [#32..#129,#135,#141,#148,#152,#153,#154,#158,#159,#166,#167];
  Numbers   : CharSet = [#48..#57];
  Tellers   : CharSet = [#45,#48..#57];
  Letters   : CharSet = [#32,#65..#90,#97..#122,#128,#129,#135,#141,#148,#152,#153,#154,#158,#159,#166,#167];

       Procedure Clrs;
       Procedure Run(RunFile,CmdLine : String);
       Function  Len(s:String):Byte;
       Function  GetKey(Var k:Byte):Char;
       Procedure BeginProg;
       Procedure EndProg;
       Function  ScrAdr:Word;
       Function  Exist(S:String):Boolean;
       Procedure CursorOff;
       Procedure CursorSmall;
       Procedure CursorBig;
       Procedure Back(ch:Char);
       Procedure Color(a,b:Integer);
       Procedure Wrt(x,y:Integer;z:String;tc,bc:Integer);
       Procedure Box(x1,y1,x2,y2,tc,bc:Integer);
       Procedure Clr(x1,y1,x2,y2,tc,bc:Integer);
       Procedure GetScr(Num:Byte);
       Procedure PutScr(Num:Byte);
       Function  BarMenu(x,y:Integer;z:String;tc,bc:Integer;full:Boolean):Byte;
       Procedure EditLine(Var s:String;x,y,len1,len2,tc,bc:Byte;Var cnt,exitcode:Byte;Perimeter:Str2;tip:Byte);
         { Tip 1->String
               2->Number }
       Procedure EditScr(s1,s2,s3,s4,s5,s6,s7:String;Perimeter:Str2);
       Procedure Message(s:String);
       Procedure Changedir(s:String);
       Function  GetScrChar(x,y:Byte):Byte;

  Implementation

    Var
      regs:Registers;

    Procedure Clrs;
      Begin
        Clrscr;
      End;

    Procedure Run(RunFile,CmdLine : String);
       Begin
            If not Exist(RunFile) then
               Begin
                  Message('File Not Found');
                  Exit;
               End;
            SwapVectors;
            Exec(RunFile,CmdLine);
            SwapVectors;
       End;

     Function Len(s:String):Byte;
       Begin Len:=Length(s);End;

     Function  GetKey(Var k:Byte):Char;
       Var
         c:Char;
       Begin
         c:=Readkey;
         If c=#0 Then
            Begin
               c:=Readkey;
               k:=0;
               GetKey:=c;
               Exit;
            End
         Else
             Begin
               GetKey:=c;
               k:=1;
               Exit;
             End;
       End;

     Procedure BeginProg;
        Begin
          ox   :=Wherex;
          oy   :=Wherey;
          oattr:=TextAttr;
          GetScr(1);
        End;

     Procedure EndProg;
        Begin
          Gotoxy(ox,oy);
          TextAttr:=Oattr;
          PutScr(1);
        End;


     Function  Exist(s:String):Boolean;
        Begin
           Assign(f,s);
           {$i-}
           Reset(f);
           {$i+}
           If IoResult <> 0 Then  Exist:=False
             Else
               Begin
                 Exist:=True;
                 Close(f);
               End;
        End;




(*********************************
  Ekranin renkli olup olmamasina
  gore ekran baslangic adresini
  bulur.
**********************************)
       Function ScrAdr:Word;
         Begin
           If Mem[$40:$49]=7 Then ScrAdr:=$B000 Else ScrAdr:=$B800;
         End;

    Procedure CursorOff;
       Begin
            FillChar(Regs,SizeOf(Regs),0);
            Regs.Ah:=$01;
            Regs.Ch:=$20;
            Regs.Cl:=$20;
            Intr($10,Regs);
       End;

    Procedure CursorSmall;
       Begin
            FillChar(Regs,SizeOf(Regs),0);
            Regs.Ah:=$01;
            Case Scradr Of
                 $B000:Begin Regs.Ch:=12; Regs.Cl:=13; End;
                 $B800:Begin Regs.Ch:=6;  Regs.Cl:=7;  End;
            End;
            Intr($10,Regs);
       End;

    Procedure CursorBig;
            Begin
                 FillChar(Regs,SizeOf(Regs),0);
                 Regs.Ah:=1;
                 Regs.Ch:=0;
                 Case ScrAdr Of
                      $B000: Regs.Cl:=13;
                      $B800: Regs.CL:=7;
                 End;
                 Intr($10,Regs);
            End;
   Function MakeStr(k:Byte):String;
      Var
        j:String;
        a:Byte;
      Begin
        j:='';
        For a:=1 to k Do j:=j+' ';
        MakeStr:=j;
      End;

   Function RTrim(s:String):String;
        Begin
             While s[Length(s)]=' ' do dec(s[0]);
             RTrim:=s;
        End;
(*********************************
  Z karakterini x,y koordinatina
  yazar.Direkt olarak hafizayi
  kullanir.
**********************************)
       Procedure Pb(x,y:Integer;z:Char);
         Var a:Word;
         Begin
            a:=(y-1)*160+(x-1)*2;
            Mem[ScrAdr:a]:=Ord(z);
            Mem[ScrAdr:a+1]:=TextAttr;
         End;


(*********************************
  Butun ekrani ch karakteri ile
  doldurur.
**********************************)
       Procedure Back(ch:Char);
         Var a:Integer;
         Begin
            for a:=0 to 2000 do
               Begin
                    Mem[ScrAdr:(a*2)]:=ord(ch);
                    Mem[ScrAdr:(a*2)+1]:=TextAttr;
               End;
          End;

(*********************************
   Yazi rengini degistirir.
**********************************)
       Procedure Color(a,b:Integer);
         Begin
           TextColor(a);
           TextBackGround(b);
         End;

(*********************************
  Z stringini tc,bc renkleri ile
  x,y koordinatina yazar.Direkt
  olarak hafizayi kullanir.
**********************************)
       Procedure Wrt(x,y:Integer;z:String;tc,bc:Integer);
         Var
            i:Integer;
            oldattr:Byte;
         Begin
            OldAttr:=TextAttr;
            Color(tc,bc);
            For i:=1 to Length(z) Do Pb(x+(i-1),y,z[i]);
            TextAttr:=OldAttr;
          End;

(*********************************
  Verilen koordinatlara kutu cizer.
**********************************)
       Procedure Box(x1,y1,x2,y2,tc,bc:Integer);
         Var
            i:Integer;
            oldattr:Byte;
         Begin
           OldAttr:=TextAttr;
           Color(tc,bc);
           For i:=x1+1 to x2-1 Do
               Begin Pb(i,y1,'Í');Pb(i,y2,'Í');End;
           For i:=y1+1 to y2-1 Do
               Begin Pb(x1,i,'º');Pb(x2,i,'º');End;
           Pb(x1,y1,'É');Pb(x2,y1,'»');Pb(x1,y2,'È');Pb(x2,y2,'¼');
           TextAttr:=OldAttr;
         End;

(*********************************
  Verilen koordinatlari temizler.
**********************************)
       Procedure Clr(x1,y1,x2,y2,tc,bc:Integer);
         Var OldCol:Byte;
         Begin
           Window(x1,y1,x2,y2);
           OldCol:=TextAttr;
           Color(tc,bc);
           Clrscr;
           Window(1,1,80,25);
           TextAttr:=OldCol;
         End;

(*********************************
   Tum ekrani hafizaya alir.
**********************************)
    Procedure GetScr;
      Var
        s:String;
      begin
        If Num>6 Then
           Begin
             Str(Num,s);
             Assign(f,'ekr'+s+'.win');
             Rewrite(f);
             Move(mem[scradr:0000],k.ekr[1],4000);
             Write(f,k);
             Close(f);
           End Else
                   Move(mem[scradr:0000],screens[num].ekr[1],4000);
      End;


(*********************************
   Hafizaya alinan ekrani tekrar
   ekrana cizer.
**********************************)
    Procedure PutScr;
      Var
        s:String;
      Begin
        If Num>6 Then
           Begin
             Str(Num,s);
             Assign(f,'ekr'+s+'.win');
             Reset(f);
             Read(f,k);
             Move(k.ekr[1],mem[scradr:0000],4000);
             Close(f);
             Erase(f);
           End Else
             Move(Screens[Num].ekr[1],mem[scradr:0000],4000);
         End;

(**************************************************************
   MENU
**************************************************************)
       Function  BarMenu(x,y:Integer;z:String;tc,bc:Integer;full:Boolean):Byte;
          Var
            Mn: Array [1..23] of string[76];
            Max:Integer;
            i,j,xx,yy:Integer;
            Ch:Char;
            ExitState:Boolean;
            attr:Byte;
           Label Bas;
          Function Stri(z:String):String;
            Var
              q:String;
              l:Integer;
            Begin
              q:='';
              for l:=Length(z) to Max-1 do q:=q+' ';
              Stri:=z+q;
            End;
          Begin
            Getscr(1);
            CursorOff;
            attr:=TextAttr;
            j:=1;Max:=0;
            For i:=1 to 23 do Mn[i]:='';
            For i:=1 to Length(z) Do
                  if (copy(z,i,1)<>'_') Then Mn[j]:=Mn[j]+z[i]
                    Else Inc(j);
            For i:=1 to j do If Max<Length(Mn[i]) Then Max:=Length(mn[i]);
            For i:=1 to j do Mn[i]:=Stri(Mn[i]);
            Clr(x,y,x+Max+3,y+j+1,tc,bc);
            Box(x,y,x+Max+3,y+j+1,tc,bc);
            For i:=1 to j do Wrt(x+2,y+i,Mn[i],tc,bc);
            ExitState:=False;
            xx:=1;yy:=2;
          Bas:
            If ExitState Then
               Begin
                  TextAttr:=Attr;
                  Putscr(1);
                  CursorSmall;
                  Exit;
               End;
            Wrt(x+2,y+xx,Mn[xx],bc,tc);
            Wrt(x+2,y+yy,Mn[yy],tc,bc);

            Ch:=Readkey;
              Case ch of
                #27:Begin
                      BarMenu:=0;
                      ExitState:=True;
                      Goto Bas;
                    end;
                #13:Begin
                      BarMenu:=xx;
                      ExitState:=True;
                      Goto Bas;
                    end;
                #0:Begin
                     Case Readkey of
                       #75:Begin
                            if full then
                               begin
                                 Barmenu:=253;
                                 Exitstate:=True;
                                 Goto Bas;
                               End
                               else
                                   Begin
                                      ExitState:=False;
                                      Goto Bas;
                                   End;
                            End;
                       #77:Begin
                            if full then
                               begin
                                 Barmenu:=254;
                                 Exitstate:=True;
                                 Goto Bas;
                               End
                               else
                                   Begin
                                      ExitState:=False;
                                      Goto Bas;
                                   End;
                            End;
                       #72:Begin
                             If xx>1 Then
                                Begin
                                  Dec(xx);
                                  yy:=xx+1;
                                  Goto Bas;
                                End
                                Else
                                    Begin
                                      xx:=j;
                                      yy:=1;
                                      Goto Bas;
                                    End;
                           End;
                       #80:Begin
                             If xx<j Then
                                Begin
                                  Inc(xx);
                                  yy:=xx-1;
                                  Goto Bas;
                                End
                                Else
                                    Begin
                                      xx:=1;
                                      yy:=j;
                                      Goto Bas;
                                    End;
                           End;
                     End;
                   End;
              End;
           end;
(******************************
  Data Entry Routine
*******************************)
   Procedure EditLine(Var s:String;x,y,len1,len2,tc,bc:Byte;Var cnt,exitcode:Byte;Perimeter:Str2;Tip:Byte);
      Var
        a,b,x1,x2       :Integer;
        ch              :Char;
        InsOn,exitok    :Boolean;
        q               :String;
        Control         :Byte;
      Label Loop,ex;
      begin
        Control:=cnt;
        x1:=1;x2:=0;
        CursorBig;
        InsOn:=False;
        mem[0:$417]:=(mem[0:$417] and 127);
        If length(s) < Len2 Then s:=s+MakeStr(len2-Length(s));
        If Length(s)>len1 Then
           Begin
                Wrt(x,y,Copy(s,1,len1),tc,bc);
                Wrt(x-1,y,Perimeter[1],bc,tc);
                Wrt(x+len1,y,Perimeter[2],bc,tc);
           End
           Else Begin
                     Wrt(x-1,y,Perimeter[1],bc,tc);
                     Wrt(x,y,makestr(len1),tc,bc);
                     Wrt(x+len1,y,Perimeter[2],bc,tc);
                     Wrt(x,y,s,tc,bc);
                 End;
          
    Loop:
           Gotoxy(x+x1-1,y);
           Ch:=Readkey;
             case ch of
                 #13:Begin
                        ExitOk:=False;
                        If (control and 1) > 0 Then
                          Begin
                             If Rtrim(s) ='' Then
                                Begin
                                  If (Control and 16) > 0 Then
                                     Begin
                                       ExitOk:=True;
                                       Exitcode:=1;
                                       Goto Ex;
                                     End
                                  Else  Begin
                                             ExitOk:=False;
                                             Goto Ex;
                                        End;
                                End Else
                                      Begin
                                         s:=Rtrim(s);
                                         ExitOk:=True;
                                         Exitcode:=1;
                                         Goto ex;
                                      End;
                          End;
                         ex:
                            If exitok Then Exit;
                     End;
                 #27:Begin
                       If (control and 2) > 0 Then
                          Begin
                               s:=#27;
                               Exitcode:=2;
                               Exit;
                          End;
                     End;
                 #8 :Begin
                       If x1+x2 > 1 Then
                          Begin
                            Delete(s,x1+x2-1,1);Insert(' ',s,length(s));
                            Wrt(x,y,Copy(s,x2,Len1),Tc,bc);
                            Dec(x1);
                            Goto Loop;
                          End;
                     End;
                 #32..#167:Begin
                         Case Tip of
                            1:Begin
                             if ch in Printable Then
                                Begin
                                  If x1<=Len1 Then
                                      Begin
                                         if (mem[0:$417] shr 7)=1 Then
                                           Begin
                                             Delete(s,Length(s),1);
                                             Inc(x1);
                                             If x1>=Len1 Then x1:=Len1;
                                             Insert(ch,s,x1+x2-1);
                                             Wrt(x,y,Copy(s,x2,len1),tc,bc);
                                             Goto Loop;
                                           End Else
                                            Begin
                                             s[x1+x2]:=ch;
                                             Wrt(x+x1-1,y,s[x1+x2],tc,bc);
                                             Inc(x1);
                                             Goto Loop;
                                           End

                                      End;
                                  If x1=len1 Then
                                     Begin
                                       If x2<(Len2-Len1)-1 Then
                                          Begin
                                            s[x1+x2]:=ch;
                                            Wrt(x,y,Copy(s,x2,len1),tc,bc);
                                            Inc(x2);
                                            x1:=len1;
                                            Goto Loop;
                                          End;
                                     End;
                                End;
                            End;
                         2:Begin
                             if ch in [#48..#57] Then
                                Begin
                                  If x1<Len1 Then
                                      Begin
                                         if (mem[0:$417] shr 7)=1 Then
                                           Begin
                                             Delete(s,Length(s),1);
                                             Inc(x1);
                                             Insert(ch,s,x1+x2-1);
                                             Wrt(x,y,Copy(s,x2,len1),tc,bc);
                                             Goto Loop;
                                           End Else
                                            Begin
                                             s[x1+x2]:=ch;
                                             Wrt(x+x1-1,y,s[x1+x2],tc,bc);
                                             Inc(x1);
                                             Goto Loop;
                                           End

                                      End;
                                  If x1=len1 Then
                                     Begin
                                       If x2<(Len2-Len1)-1 Then
                                          Begin
                                            s[x1+x2]:=ch;
                                            Wrt(x,y,Copy(s,x2,len1),tc,bc);
                                            Inc(x2);
                                            x1:=len1;
                                            Goto Loop;
                                          End;
                                     End;
                                End;
                            End;
                         End;
                     End;
                 #0:Begin
                      Case ReadKey Of
                         #80:Begin
                               if (control and 8) > 0 Then
                                  Begin
                                       s:=Rtrim(s);
                                       Exitcode:=8;
                                       Exit;
                                  End;
                             End;
                         #72:Begin
                               If (control and 4) > 0 Then
                                  Begin
                                       s:=Rtrim(s);
                                       Exitcode:=4;
                                       Exit;
                                  End;
                             End;
                         #71:Begin    { Home }
                               x1:=1;
                               x2:=0;
                               Wrt(x,y,Copy(s,1,len1),tc,bc);
                               Goto Loop;
                             End;
                         #79:Begin    {  End }
                               x1:=Len1;
                               x2:=Len2-Len1;
                               Wrt(x,y,Copy(s,Len2-Len1,Len1),tc,bc);
                               Goto Loop;
                             End;
                         #83:Begin     { Delete }
                             q:=s;
                             Delete(q,x1+x2,1);
                             s:=q;
                             Wrt(x+x1-1,y,Copy(s,x1+x2,len1-x1+1),tc,bc);
                             Goto Loop
                           End;
                         #75:Begin
                                if x1>1 Then
                                  Begin
                                     Dec(x1);
                                     Goto Loop;
                                  End;
                                If (x1=1) and (x2>=1) Then
                                  Begin
                                     dec(x2);
                                     Wrt(x,y,copy(s,x2,len1),tc,bc);
                                     Goto Loop;
                                  End;
                             End;
                         #77:Begin
                                If x1 < Len1 Then
                                   Begin
                                      Inc(x1);
                                      Goto Loop;
                                   End;
                                If x1=Len1 Then
                                    Begin
                                      If x2<(Len2-len1) Then
                                         Begin
                                           Inc(x2);
                                           Wrt(x,y,copy(s,x2,len1),tc,bc);
                                           Goto Loop;
                                         End;
                                    End;
                             End;
                      End;
                    End;
             End;
         Goto Loop;
      end;
{**************************************
   Data Entry building...
****************************************}

     Procedure EditScr(s1,s2,s3,s4,s5,s6,s7:String;Perimeter:Str2);
       Var
          Lab:Array [1..50] of String[30];
          b,x,ctrl:Byte;
       Label Loop,fin;
     Procedure GetParameters;
          Var
            a:Integer;
            c:Char;
            ss1,ss2:String;
            i,x,y:Integer;
          Begin
            b:=1;
            ss1:='';
            For a:=1 to 50 Do
                Begin
                   Edits[a].data:='';
                   Edits[a].x:=0;
                   Edits[a].y:=0;
                   Edits[a].len1:=0;
                   Edits[a].len2:=0;
                   Edits[a].tc:=0;
                   Edits[a].bc:=0;
                   Edits[a].cnt:=0;
                   Lab[a]:='';
                End;
            For a:=1 to Length(s1) Do    { Entry data }
                Begin
                   If s1[a]<>'_' Then Edits[b].data:=Edits[b].data+s1[a]
                      Else Inc(b)
                End;
            b:=1;
            For a:=1 to Length(s2) Do    { Entry Label }
                Begin
                   If s2[a]<>'_' Then Lab[b]:=Lab[b]+s2[a]
                      Else Inc(b)
                End;
            b:=1;
            ss1:='';
            For a:=1 to Length(s3) do     { Entry coords }
                    Begin
                         if (s3[a] <> ',') and
                            (s3[a] <> '_') Then ss1:=ss1+s3[a];
                         If s3[a]=',' Then
                            Begin
                                 Val(ss1,x,i);
                                 Edits[b].x:=x;
                                 ss1:='';
                            End;
                         If (s3[a]='_') or
                            (a=Length(s3)) Then
                            Begin
                                 Val(ss1,y,i);
                                 Edits[b].y:=y;
                                 Inc(b);
                                 ss1:='';
                            End;
                    End;
            b:=1;
            ss1:='';
            For a:=1 to Length(s4) do     { Entry Length }
                    Begin
                         if (s4[a] <> ',') and
                            (s4[a] <> '_') Then ss1:=ss1+s4[a];
                         If s4[a]=',' Then
                            Begin
                                 Val(ss1,x,i);
                                 Edits[b].Len1:=x;
                                 ss1:='';
                            End;
                         If (s4[a]='_') or
                            (a=Length(s4)) Then
                            Begin
                                 Val(ss1,y,i);
                                 Edits[b].Len2:=y;
                                 Inc(b);
                                 ss1:='';
                            End;
                    End;
            b:=1;
            ss1:='';
            For a:=1 to Length(s5) do     { Entry Color }
                    Begin
                         if (s5[a] <> ',') and
                            (s5[a] <> '_') Then ss1:=ss1+s5[a];
                         If s5[a]=',' Then
                            Begin
                                 Val(ss1,x,i);
                                 Edits[b].tc:=x;
                                 ss1:='';
                            End;
                         If (s5[a]='_') or
                            (a=Length(s5)) Then
                            Begin
                                 Val(ss1,y,i);
                                 Edits[b].bc:=y;
                                 Inc(b);
                                 ss1:='';
                            End;
                    End;
            ss1:='';
            b:=1;
              For a:=1 to Length(s6) Do    { Entry control }
                Begin
                   If s6[a]<>'_' Then ss1:=ss1+s6[a]
                      Else
                          Begin
                            Val(ss1,x,i);
                            Edits[b].cnt:=x;
                            ss1:='';
                            Inc(b);
                          End;
                      Val(ss1,x,i);
                      Edits[b].cnt:=x;
                End;
              ss1:='';
              b:=1;
              For a:=1 to Length(s7) Do    { Tip control }
                Begin
                   If s7[a]<>'_' Then ss1:=ss1+s7[a]
                      Else
                          Begin
                            Val(ss1,x,i);
                            Edits[b].tip:=x;
                            ss1:='';
                            Inc(b);
                          End;
                      Val(ss1,x,i);
                      Edits[b].tip:=x;
                End;

          End;

       Procedure SetScreen;
         Var a:Integer;
         Begin
           For a:=1 to b Do
               Begin
                 GetScr(1);
                 Wrt(Edits[a].x,Edits[a].y,Lab[a],Edits[a].tc,Edits[a].bc);
                 Wrt(Edits[a].x+Length(Lab[a])+1,Edits[a].y,Perimeter[1],Edits[a].tc,Edits[a].bc);
                 Wrt(Edits[a].x+Length(Lab[a])+2,Edits[a].y,Makestr(Edits[a].Len1),Edits[a].bc,Edits[a].tc);
                 Wrt(Edits[a].x+Length(Lab[a])+2+Edits[a].len1,Edits[a].y,Perimeter[2],Edits[a].tc,Edits[a].bc);
               End;
         end;
       Begin
          GetParameters;
          SetScreen;
          x:=1;
          Loop:
            Editline(edits[x].data,Edits[x].x+Length(Lab[x])+2,Edits[x].y,
                     Edits[x].Len1,Edits[x].Len2,Edits[x].bc,Edits[x].tc,
                     Edits[x].cnt,ctrl,Perimeter,edits[x].tip);
            Case Ctrl Of
                 1:Begin
                       If x=b Then Goto Fin
                         Else
                             Begin
                               Inc(x);
                               Goto Loop;
                             End;
                   End;
                 2:Begin
                     Goto Fin;
                   End;
                 8:Begin
                      If x=b Then
                         Begin
                              x:=1;
                              Goto Loop;
                         End Else
                             Begin
                               Inc(x);
                               Goto Loop;
                             End;
                      End;
                 4:Begin
                      If x=1 Then
                         Begin
                              x:=b;
                              Goto Loop;
                         End Else
                             Begin
                               Dec(x);
                               Goto Loop;
                             End;
                      End;
             End;
          Goto Loop;
         Fin:
           PutScr(1);
       End;
    Procedure Message(s:String);
      Begin
        Getscr(4);
        Clr(15,5,65,11,0,7);
        Box(15,5,65,11,0,7);
        Wrt(20,7,s,0,7);
        Wrt(36,9,' Ok  ',7,0);
        Repeat Until (Readkey=#13) or (Readkey=#27);
        Putscr(4);
      End;
    Procedure ChangeDir(s:String);
      Begin
        {$i-}
        Chdir(s);
        {$i+}
        If IoResult <> 0 Then
           Begin
              Message('Path Not Found');
              Exit;
           End;
      End;
   Function GetscrChar(x,y:Byte):Byte;
     Var
       a:Word;
     Begin
       a:=(y-1)*160+(x-1)*2;
       GetScrChar:=Mem[scradr:a];
     End;

  End.
