program DrillingOptimize;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  MainFormUnit
  { you can add units after this };

begin
  RequireDerivedFormResource := True;
  Application.SynchronizeFormWakeups := False;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
