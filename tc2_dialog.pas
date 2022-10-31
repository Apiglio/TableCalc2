unit tc2_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TDialog_TC2 }

  TDialog_TC2 = class(TForm)
    Button_OK: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button_OKClick(Sender: TObject);
  protected
    function GetValue(index:integer):string;
  public
    procedure Call(title:string;labels:array of string;default_values:array of string);
    property Values[index:integer]:string read GetValue;
  end;

var
  Dialog_TC2: TDialog_TC2;

implementation

{$R *.lfm}

procedure TDialog_TC2.Button_OKClick(Sender: TObject);
begin

end;

function TDialog_TC2.GetValue(index:integer):string;
begin
  case index of
    0:result:=Edit1.Caption;
    1:result:=Edit2.Caption;
    2:result:=Edit3.Caption;
    else result:='';
  end;
end;

procedure TDialog_TC2.Call(title:string;labels:array of string;default_values:array of string);
var ll,ld:integer;
begin
  ll:=length(labels);
  ld:=length(default_values);
  Label1.Caption:=labels[0];
  if ll>1 then begin
    Label2.Caption:=labels[1];
    Label2.Visible:=true;
    Edit2.Visible:=true;
  end else begin
    Label2.Caption:='';
    Label2.Visible:=false;
    Edit2.Visible:=false;
  end;
  if ll>2 then begin
    Label3.Caption:=labels[2];
    Label3.Visible:=true;
    Edit3.Visible:=true;
  end else begin
    Label3.Caption:='';
    Label3.Visible:=false;
    Edit3.Visible:=false;
  end;

  if ld>0 then Edit1.Caption:=default_values[0] else Edit1.Caption:='';
  if ld>1 then Edit2.Caption:=default_values[1] else Edit2.Caption:='';
  if ld>2 then Edit3.Caption:=default_values[2] else Edit3.Caption:='';


  Caption:=title;
  ShowModal;
end;

end.

