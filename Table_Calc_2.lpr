program Table_Calc_2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, tc2_mainform, tc2_network, tc2_geojson, tc2_dialog
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TForm_Main, Form_Main);
  Application.CreateForm(TDialog_TC2, Dialog_TC2);
  Application.Run;
end.

