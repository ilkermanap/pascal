{****************************************************************************}
{**                                                                        **}
{**     Bu komutlarin buyuk bolumu shareware programlardan alinmistir.     **}
{**                                                                        **}
{**     27/7/1993                                                          **}
{**                                                                        **}
{****************************************************************************}

Unit Crt02;
 Interface
  Uses Dos,crt01;
   Type
      Cursor=Record
         Startl,endl,x,y:Byte;
      End;
   
       Function  MakeUpcase(s:String):String;
       Function  PathOnly(FileName : String) : String;
       Function  NameOnly(FileName : String) : String;
       Function  BaseNameOnly(FileName : String) : String;
       Function  ExtOnly(FileName : String) : String;
       Function  IntStr(Int : LongInt; Form : Integer) : String;
       Procedure Go(x,y:Byte);
       Procedure GetCursor(Var c:Cursor);

{************************************************************************** }

Implementation

{************************************************************************* }

      Var
        Regs:Registers;
        cr:Cursor;
      Function MakeUpCase(s:String):String;

         Var
            a:Byte;
         Begin
           For a:=1 to Len(s) Do
               Begin
                  If s[a]=#105 Then s[a]:=#152;     { i -> ˜ }
                  If s[a]=#129 Then s[a]:=#154;     {  -> š }
                  If s[a]=#135 Then s[a]:=#128;     { ‡ -> € }
                  If s[a]=#141 Then s[a]:=#73;      {  -> I }
                  If s[a]=#148 Then s[a]:=#153;     { ” -> ™ }
                  If s[a]=#159 Then s[a]:=#158;     { Ÿ -> ž }
                  If s[a]=#167 Then s[a]:=#166;     { § -> ¦ }
                  s[a]:=Upcase(s[a]);
               End;
           MakeUpCase:=s;
         End;

      Function PathOnly(FileName : String) : String;
           Var
              Dir  : DirStr;
              Name : NameStr;
              Ext  : ExtStr;
           Begin
                FSplit(FileName, Dir, Name, Ext);
                PathOnly := Dir;
           End {PathOnly};

{ *************************************************************************** }

      Function NameOnly(FileName : String) : String;
           Var
              Dir  : DirStr;
              Name : NameStr;
              Ext  : ExtStr;
           Begin
                FSplit(FileName, Dir, Name, Ext);
                NameOnly := Name + Ext;
           End {NameOnly};

{ **************************************************************************- }

      Function BaseNameOnly(FileName : String) : String;
           Var
              Dir  : DirStr;
              Name : NameStr;
              Ext  : ExtStr;
           Begin
                FSplit(FileName, Dir, Name, Ext);
                BaseNameOnly := Name;
           End {BaseNameOnly};

{ **************************************************************************- }

      Function ExtOnly(FileName : String) : String;
          Var
             Dir  : DirStr;
             Name : NameStr;
             Ext  : ExtStr;
          Begin
               FSplit(FileName, Dir, Name, Ext);
               If Pos('.', Ext) <> 0 then
               Delete(Ext, 1, 1);
               ExtOnly := Ext;
          End {ExtOnly};

{ **************************************************************************- }

      Function IntStr(Int : LongInt; Form : Integer) : String;
           Var
              S : String;
           Begin
                If Form = 0 then
                Str(Int, S)
                else
                    Str(Int:Form, S);
                IntStr := S;
           End {IntStr};

      Procedure Go(x,y:Byte);
         Begin
           regs.ah:=$02;
           regs.dh:=x;
           regs.dl:=y;
           Intr($10,regs);

         End;

      Procedure GetCursor(Var c:Cursor);
        Begin
          Regs.AH:=03;
          Intr($10,Regs);
          c.Startl:=Regs.ch;
          c.Endl  :=Regs.cl;
          c.x     :=Regs.Dh;
          c.Y     :=Regs.DL;
        End;
   End {Unit StrProcs}.
