Unit Crt03;
  Interface
    Uses Crt01;
    Type
      ListContent=Array [1..1000] of string[60];
      Listptr=^ListContent;
    Var
      List:ListPtr;
      NumLines:Integer;

   Procedure ClearList;
   Function GetName(x,y,tc,bc:Byte):Integer;

  Implementation

    Procedure ClearList;
      Var
        a:Integer;
      Begin
        For a:=1 to 1000 do List^[a]:='';
      End;

    Function GetName(x,y,tc,bc:Byte):Integer;
      Var
        a,b,c,x1,y1,rx1,ry1:Integer;
        Max,k:Byte;
        ch:Char;
        ExitOk:Boolean;
      Label Loop;
      Function StrMake(a:Byte):String;
        Var
          j:String;
          k:Byte;
        Begin
          j:='';k:=0;
          For k:=1 to  Max-Len(List^[a]) Do j:=j+' ';
          StrMake:=List^[a]+j;
        End;
      Begin
        GetScr(1);
        Max:=0;
        ExitOk:=False;
        For a:=1 to NumLines Do   { Finding maximum length }
               If Len(List^[a]) > Max Then Max:=Len(List^[a]);
        For a:=1 to NumLines Do List^[a]:=StrMake(a);
        If NumLines < 10 Then a:=NumLines Else a:=10;
        GetScr(6);
        Box(x,y,x+Max+1,y+11,tc,bc);
        For b:=1 to a Do
            Begin
               Wrt(x+1,y+b,List^[b],tc,bc);
            End;
        x1:=1;y1:=2;
        rx1:=1;ry1:=2;
     Loop:
        If ExitOk Then
           Begin
             PutScr(6);
             Exit;
           End;
        Wrt(x+1,y+x1,List^[rx1],bc,tc);
        Wrt(x+1,y+y1,List^[ry1],tc,bc);
        Ch:=GetKey(k);
        If k=1 Then
           Begin
             Case ch of
               #13:Begin
                     ExitOk:=True;
                     GetName:=Rx1;
                     Goto Loop;
                   End;
               #27:Begin
                     ExitOk:=True;
                     GetName:=-1;
                     Goto Loop;
                   End;
             End;
           End;
        if k=0 Then
           Case ch of
              #73:Begin    {  Page Up }
                    If rx1 <= 10 Then
                       Begin
                         Rx1:=1;
                         x1:=1;
                         Ry1:=2;
                         y1:=2;
                         For b:=1 to a do Wrt(x+1,y+b,List^[b],tc,bc);
                         Goto Loop;
                       End;
                    If Rx1 > 10 Then
                       Begin
                         Dec(Rx1,10);
                         x1:=1;y1:=2;
                         Ry1:=Rx1+1;
                         For b:=1 to 10 do Wrt(x+1,y+b,List^[Rx1+b-1],tc,bc);
                         Goto Loop;
                       End;
                  End;
              #81:Begin    {  Page Down }
                   If NumLines > 10 Then
                    Begin
                     If (rx1+10 >= NumLines) Then
                       Begin
                         For b:=1 to a do Wrt(x+1,y+b,List^[Numlines-10+b],tc,bc);
                         Rx1:=Numlines;
                         x1:=10;
                         Ry1:=Numlines-1;
                         y1:=9;
                         Goto Loop;
                       End;
                    If (Rx1+10 < NumLines) Then
                       Begin
                         For b:=1 to 10 do Wrt(x+1,y+b,List^[Rx1+b],tc,bc);
                         rx1:=rx1+10;
                         x1:=10;
                         y1:=9;
                         Ry1:=Rx1-1;
                         Goto Loop;
                       End;
                    End;
                   End;
              #72:Begin
                    If x1>1 Then
                       Begin
                         Dec(rx1);
                         Dec(x1);
                         Ry1:=rx1+1;
                         y1:=x1+1;
                         Goto Loop;
                       End;
                    If x1=1 Then
                       Begin
                         If rx1=1 Then Goto Loop;
                         Dec(rx1);
                         For c:=1 to a Do Wrt(x+1,y+c,List^[rx1+c-1],tc,bc);
                         Wrt(x+1,y+x1,List^[rx1],bc,tc);
                         ry1:=rx1+1;
                         y1:=2;
                         Goto Loop;
                       End;
                  End;
              #80:Begin
                    If x1<a Then
                       Begin
                         Inc(rx1);
                         Inc(x1);
                         Ry1:=rx1-1;
                         y1:=x1-1;
                         Goto Loop;
                       End;
                    If (x1=a) and (a=10) Then
                       Begin
                         If rx1=NumLines Then Goto Loop;
                         Inc(rx1);
                         For c:=1 to a Do Wrt(x+1,y+c,List^[rx1+c-10],tc,bc);
                         ry1:=rx1-8;
                         y1:=2;
                         Goto Loop;
                       End;
                  End;

           End; {Case}
         Goto Loop;
      End;
  End.
