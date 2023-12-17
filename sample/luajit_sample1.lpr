program luajit_sample1;

{$mode objfpc}{$H+}

uses
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads,
    {$ENDIF}{$ENDIF}
    Interfaces, // this includes the LCL widgetset
    Forms, luajit_sample1_unit
    { you can add units after this };

{$R *.res}

{$IFNDEF DARWIN}
exports
    test_fn;
{$ENDIF}

begin
    RequireDerivedFormResource := True;
    Application.Initialize;
    Application.CreateForm(TForm1, Form1);
    Application.Run;
end.

