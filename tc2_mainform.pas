unit tc2_mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, Spin, Grids, LazUTF8, SpinEx, Apiglio_Useful,
  aufscript_frame, auf_ram_var, tc2_network, Types;

const NA:double=$7fffffffffffffff;

type

  { TForm_Main }

  TForm_Main = class(TForm)
    Button_Export_SG: TButton;
    CheckBox_ShowODs: TCheckBox;
    CheckBox_ShowNodes: TCheckBox;
    CheckBox_EdgeLabel: TCheckBox;
    CheckBox_NodeLabel: TCheckBox;
    CheckBox_ActorLabel: TCheckBox;
    CheckBox_ShowArrow: TCheckBox;
    CheckBox_ShowEdges: TCheckBox;
    CheckBox_ShowActors: TCheckBox;
    Edit_ExportName: TEdit;
    FloatSpinEdit_EdgeWidth: TFloatSpinEdit;
    FloatSpinEditEx_Top: TFloatSpinEditEx;
    FloatSpinEditEx_Left: TFloatSpinEditEx;
    FloatSpinEditEx_Right: TFloatSpinEditEx;
    FloatSpinEditEx_Bottom: TFloatSpinEditEx;
    FloatSpinEdit_NodeSize: TFloatSpinEdit;
    Frame_AufScript1: TFrame_AufScript;
    Label_EdgeWidth: TLabel;
    Label_NodeSize: TLabel;
    Label_LayoutOpt: TLabel;
    PageControl_DataView: TPageControl;
    ScrollBox_ActorOption: TScrollBox;
    ScrollBox_ODOption: TScrollBox;
    ScrollBox_PaintBox: TScrollBox;
    ScrollBox_LayoutOption: TScrollBox;
    ScrollBox_EdgeOption: TScrollBox;
    ScrollBox_NodeOption: TScrollBox;
    PageControl1: TPageControl;
    PaintBox_Net: TPaintBox;
    RadioGroup_EdgeLabel: TRadioGroup;
    RadioGroup_NodeLabel: TRadioGroup;
    Splitter: TSplitter;
    Splitter_Auto: TSplitter;
    StringGrid_DV_Node: TStringGrid;
    StringGrid_DV_Edge: TStringGrid;
    StringGrid_DV_Actor: TStringGrid;
    StringGrid_DV_OD: TStringGrid;
    TabSheet_DV_Node: TTabSheet;
    TabSheet_DV_Edge: TTabSheet;
    TabSheet_DV_Actor: TTabSheet;
    TabSheet_OD: TTabSheet;
    TabSheet_DataView: TTabSheet;
    TabSheet_Layout: TTabSheet;
    TabSheet_AufScript: TTabSheet;
    TrackBar_Zone: TTrackBar;
    TrackBar_Alpha: TTrackBar;
    procedure Button_Export_SGClick(Sender: TObject);
    procedure CheckBox_EdgeLabelClick(Sender: TObject);
    procedure CheckBox_NodeLabelClick(Sender: TObject);
    procedure CheckBox_ShowArrowClick(Sender: TObject);
    procedure FloatSpinEdit_EdgeWidthEditingDone(Sender: TObject);
    procedure FloatSpinEdit_NodeSizeEditingDone(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Frame_AufScript1Resize(Sender: TObject);
    procedure PaintBox_NetPaint(Sender: TObject);
    procedure RadioGroup_EdgeLabelClick(Sender: TObject);
    procedure RadioGroup_NodeLabelClick(Sender: TObject);
    procedure StringGrid_DV_ActorEnter(Sender: TObject);
    procedure StringGrid_DV_EdgeEnter(Sender: TObject);
    procedure StringGrid_DV_NodeEnter(Sender: TObject);
    procedure StringGrid_DV_ODEnter(Sender: TObject);
    procedure TrackBar_AlphaChange(Sender: TObject);
    procedure TrackBar_ZoneChange(Sender: TObject);
  private

  public

  end;

var
  Form_Main: TForm_Main;
  netw:TTC2_Network;

implementation


function HSVToColor(H,S,V:Single):TColor;
var i,difs:integer;
    min,max,adj:byte;
    r,g,b:byte;
begin
  max:=round(V*2.55);
  min:=round(max*(100-s)) div 100;
  i:=round(H) div 60;
  difs:=round(H) mod 60;
  adj:=(max-min)*difs div 60;
  case i of
    0:begin r:=(max);g:=(min+adj);b:=(min);end;
    1:begin r:=(max-adj);g:=(max);b:=(min);end;
    2:begin r:=(min);g:=(max);b:=(min+adj);end;
    3:begin r:=(min);g:=(max-adj);b:=(max);end;
    4:begin r:=(min+adj);g:=(min);b:=(max);end
    else begin r:=(max);g:=(min);b:=(max-adj);end;
  end;
  result:=$00000000 or (b shl 16) or (g shl 8) or r;
end;

function FloatToResult(f:valreal):string;
begin
  if f=$7fffffffffffffff then result:='n/a'
  else result:=FloatToStrF(f,ffFixed,3,3);
  result:=Usf.left_adjust(result,8);
end;

procedure GetArrowPoint(p1,p2:TPoint;arrow_size:byte;out n1,n2,a1,a2:TPoint);
var len:double;
    dx,dy:integer;
begin
  if p1=p2 then exit;
  len:=sqrt(sqr(p1.x-p2.x)+sqr(p1.y-p2.y));
  dx:=round((p2.x-p1.x)*arrow_size/len/2);
  dy:=round((p2.y-p1.y)*arrow_size/len/2);

  n1.x:=p1.x+2*dx;
  n1.y:=p1.y+2*dy;
  n2.x:=p2.x-2*dx;
  n2.y:=p2.y-2*dy;

  a1.x:=n2.x-dy-3*dx;
  a1.y:=n2.y+dx-3*dy;
  a2.x:=n2.x+dy-3*dx;
  a2.y:=n2.y-dx-3*dy;
end;




procedure AufScptWritelnFunc(Sender:TObject;str:string);
begin
  (Sender as TAufScript).writeln(str);
end;


procedure FuncAddNode(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    name:string;
    arv:TAufRamVar;
    index:integer;
    xx,yy:double;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,name) then exit;
  if AAuf.ArgsCount>=3 then begin
    if not AAuf.TryArgToARV(2,4,4,[ARV_FixNum],arv) then exit;
    if AAuf.ArgsCount>=5 then begin
      if not AAuf.TryArgToDouble(3,xx) then exit;
      if not AAuf.TryArgToDouble(4,yy) then exit;
    end else begin
      xx:=0;yy:=0;
    end;
  end else begin
    arv.VarType:=ARV_Raw;
  end;
  index:=netw.AddNodeIndex(name);
  with netw.Nodes[index] do
    begin
      pos.x:=xx;
      pos.y:=yy;
      latlong.x:=xx;
      latlong.y:=yy;
    end;
  if arv.VarType=ARV_Raw then AufScpt.writeln('????????????#'+IntToStr(index))
  else dword_to_arv(index,arv);
end;
procedure FuncAddActor(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    name:string;
    arv:TAufRamVar;
    index:integer;
    xx,yy:double;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,name) then exit;
  if AAuf.ArgsCount>=3 then begin
    if not AAuf.TryArgToARV(2,4,4,[ARV_FixNum],arv) then exit;
    if AAuf.ArgsCount>=5 then begin
      if not AAuf.TryArgToDouble(3,xx) then exit;
      if not AAuf.TryArgToDouble(4,yy) then exit;
    end else begin
      xx:=0;yy:=0;
    end;
  end else begin
    arv.VarType:=ARV_Raw;
  end;
  index:=netw.AddActorIndex(name);
  with netw.Actors[index] do
    begin
      pos.x:=xx;
      pos.y:=yy;
      latlong.x:=xx;
      latlong.y:=yy;
    end;
  if arv.VarType=ARV_Raw then AufScpt.writeln('???????????????#'+IntToStr(index))
  else dword_to_arv(index,arv);
end;
procedure FuncAddEdge(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    n1,n2,index:dword;
    arv:TAufRamVar;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToDWord(1,n1) then exit;
  if not AAuf.TryArgToDWord(2,n2) then exit;
  if AAuf.ArgsCount>=4 then begin
    if not AAuf.TryArgToARV(3,4,4,[ARV_FixNum],arv) then exit;
  end else begin
    arv.VarType:=ARV_Raw;
  end;
  index:=netw.AddEdgeIndex(n1,n2);
  if arv.VarType=ARV_Raw then AufScpt.writeln('????????????#'+IntToStr(index))
  else dword_to_arv(index,arv);
end;

procedure FuncAddNodeByName(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    nodename:string;
    index:integer;
    xx,yy:double;
    mode:byte;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,nodename) then exit;
  if AAuf.ArgsCount>=4 then begin
    if not AAuf.TryArgToDouble(2,xx) then exit;
    if not AAuf.TryArgToDouble(3,yy) then exit;
    if AAuf.ArgsCount>=5 then begin
      case lowercase(AAuf.args[4]) of
        '-x':mode:=1;
        '-y':mode:=2;
        '-xy':mode:=3;
        else mode:=0;
      end;
    end else mode:=0;
  end else begin
    xx:=0;yy:=0;
  end;
  if mode mod 2 = 1 then xx:=-xx;
  if mode > 1 then yy:=-yy;
  index:=netw.FindNodeIndexByName(nodename);
  if index<0 then
    begin
      AufScpt.writeln('????????????"'+nodename+'"???');
      index:=netw.AddNodeIndex(nodename);
      with netw.Nodes[index] do
        begin
          name:=nodename;
          pos.x:=xx;
          pos.y:=yy;
          latlong.x:=xx;
          latlong.y:=yy;
        end;
    end
  else AufScpt.writeln('??????"'+nodename+'"????????????');
end;
procedure FuncAddActorByName(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    actorname:string;
    index:integer;
    xx,yy:double;
    mode:byte;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,actorname) then exit;
  if AAuf.ArgsCount>=4 then begin
    if not AAuf.TryArgToDouble(2,xx) then exit;
    if not AAuf.TryArgToDouble(3,yy) then exit;
    if AAuf.ArgsCount>=5 then begin
      case lowercase(AAuf.args[4]) of
        '-x':mode:=1;
        '-y':mode:=2;
        '-xy':mode:=3;
        else mode:=0;
      end;
    end else mode:=0;
  end else begin
    xx:=0;yy:=0;
  end;
  if mode mod 2 = 1 then xx:=-xx;
  if mode > 1 then yy:=-yy;
  index:=netw.FindActorIndexByName(actorname);
  if index<0 then
    begin
      AufScpt.writeln('???????????????"'+actorname+'"???');
      index:=netw.AddActorIndex(actorname);
      with netw.Actors[index] do
        begin
          name:=actorname;
          pos.x:=xx;
          pos.y:=yy;
          latlong.x:=xx;
          latlong.y:=yy;
        end;
    end
  else AufScpt.writeln('??????"'+actorname+'"????????????');
end;
procedure FuncAddEdgeByName(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    index:dword;
    n1,n2:string;
    na,nb:TTC2_Node;
    weight:double;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,n1) then exit;
  if not AAuf.TryArgToString(2,n2) then exit;
  if AAuf.ArgsCount>4 then
    begin
      if not AAuf.TryArgToDouble(3,weight) then exit;
    end
  else weight:=1;
  na:=netw.FindNodeByName(n1);
  nb:=netw.FindNodeByName(n2);
  if (na=nil) or (nb=nil) then AufScpt.send_error('?????????????????????????????????')
  else
    begin
      netw.AddEdge(na,nb).weight:=weight;
      AufScpt.writeln('?????????????????????');
    end;
end;

procedure FuncExportAdjCSV(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    name:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,name) then exit;
  netw.SaveToAdjacentCSV(name);
end;
procedure FuncImportAdjCSV(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    name:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,name) then exit;
  netw.LoadFromAdjacentCSV(name);
end;
procedure FuncExportGeoJson(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    name:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,name) then exit;
  netw.SaveToGeoJson(name);
end;
procedure FuncImportGeoJson(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    name:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,name) then exit;
  netw.LoadFromGeoJson(name);
end;
procedure FuncImportActorFromGeoJson(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    name:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,name) then exit;
  netw.LoadActorsFromGeoJson(name);
end;
procedure FuncDataListExport(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    filename:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;
  with Form_Main do
    begin
      StringGrid_DV_ODEnter(StringGrid_DV_OD);
      StringGrid_DV_ActorEnter(StringGrid_DV_Actor);
      StringGrid_DV_EdgeEnter(StringGrid_DV_Edge);
      StringGrid_DV_NodeEnter(StringGrid_DV_Node);
      try
        StringGrid_DV_Actor.SaveToCSVFile(filename+'_actor.csv');
        StringGrid_DV_OD.SaveToCSVFile(filename+'_od.csv');
        StringGrid_DV_Node.SaveToCSVFile(filename+'_node.csv');
        StringGrid_DV_Edge.SaveToCSVFile(filename+'_edge.csv');
        AufScpt.writeln('???????????????');
      except
        AufScpt.writeln('???????????????');
      end;
    end;
end;


procedure FuncUpdateActorsEdge(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  netw.ActorEdgeUpdate(Sender,@AufScptWritelnFunc);
end;

procedure FuncBuildBlockOD(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  netw.BuildODAsBlock;
end;
procedure FuncBuildRandomOD(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    P:double;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if AAuf.ArgsCount>=2 then begin
    if not AAuf.TryArgToDouble(1,P) then exit;
  end else begin
    P:=0.1;
  end;
  netw.BuildODAsRandom(P);
  AufScpt.writeln('??????OD??????????????????');
end;

procedure FuncImportODsFromGeoJson(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    name:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,name) then exit;
  netw.LoadODsFromGeoJson(name);
end;

procedure FuncODTest(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    a1,a2:dword;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToDWord(1,a1) then exit;
  if not AAuf.TryArgToDWord(2,a2) then exit;
  with netw do
  AufScpt.writeln('????????????????????????'+FloatToStrF(ODTest(Actors[a1],Actors[a2]),ffFixed,3,10));
end;
procedure FuncODFrequency(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  netw.ODFrequency(AufScpt);
end;








procedure FuncClear(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.Clear;
  AufScpt.writeln('??????????????????');
end;
procedure FuncBuildRand(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    V:dword;
    pi,pj:integer;
    P:double;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;

  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToDWord(1,V) then exit;
  if AAuf.ArgsCount>=3 then begin
    if not AAuf.TryArgToDouble(2,P) then exit;
  end else begin
    P:=0.5;
  end;
  for pi:=0 to V-1 do netw.AddNode('N'+IntToStr(pi));
  for pi:=0 to V-1 do for pj:=0 to V-1 do
    begin
      if pi=pj then continue;
      if random<P then netw.AddEdgeIndex(pi,pj);
    end;
  AufScpt.writeln('????????????????????????');
end;
procedure FuncIndirectGraphy(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.IndirectGraphy;
  AufScpt.writeln('????????????????????????');
end;
procedure FuncIndirectWeightCheck(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.IndirectWeightCheck(Sender,@AufScptWritelnFunc);
  AufScpt.writeln('???????????????????????????????????????');
end;
procedure FuncRemoveMidNode(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.RemoveMidNode;
  AufScpt.writeln('??????????????????????????????');
end;
procedure FuncLengthToWeight(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.SpatialEdgeWeight;
  AufScpt.writeln('???????????????????????????????????????');
end;
procedure FuncReverseWeight(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.ReverseWeight;
  AufScpt.writeln('?????????????????????');
end;
procedure FuncComplement(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.ComplementGraphy(true);
  AufScpt.writeln('???????????????');
end;
procedure FuncBipartite(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.CalcBipartiteGraphy;
  AufScpt.writeln('??????????????????????????????????????????????????????????????????');
end;





procedure FuncCalcDensity(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  AufScpt.writeln('???????????? D='+FloatToResult(netw.CalcDensity));
end;
procedure FuncCalcDiam(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  AufScpt.writeln('???????????? diam='+FloatToResult(netw.CalcDiameter));
end;
procedure FuncCalcRad(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  AufScpt.writeln('???????????? rad='+FloatToResult(netw.CalcRadius));
end;
procedure FuncCalcWiener(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  try
    AufScpt.writeln('??????Wiener?????? W='+FloatToResult(netw.CalcWiener));
  except
    AufScpt.send_error('Wiener??????????????????????????????');
  end;
end;
procedure FuncCalcClusteringCoefficient(Sender:TObject);
var AufScpt:TAufScript;
    arr:pdouble;
    pi:integer;
begin
  AufScpt:=Sender as TAufScript;
  arr:=GetMem(8*netw.NodeCount);
  AufScpt.writeln('?????????????????? C='+FloatToResult(netw.CalcClusteringCoefficient(Arr)));
  AufScpt.writeln('ID      Ci        Name');
  for pi:=0 to netw.NodeCount-1 do
    begin
      AufScpt.writeln(Usf.left_adjust(IntToStr(pi),6,6)+'  '+FloatToResult(Arr[pi])+'  '+netw.Nodes[pi].name);
    end;
  FreeMem(arr,8*netw.NodeCount);
end;
procedure FuncCalcKappa(Sender:TObject);
var AufScpt:TAufScript;
    arr:pdouble;
    pi:integer;
begin
  AufScpt:=Sender as TAufScript;
  arr:=GetMem(8*netw.NodeCount);
  AufScpt.writeln('?????????????????? K='+FloatToResult(netw.CalcConnectedComponent(Arr)));
  AufScpt.writeln('ID      Group     Name');
  for pi:=0 to netw.NodeCount-1 do
    begin
      AufScpt.writeln(Usf.left_adjust(IntToStr(pi),6,6)+'  '+FloatToResult(Arr[pi])+'  '+netw.Nodes[pi].name);
    end;
  FreeMem(arr,8*netw.NodeCount);
end;
procedure FuncCalcDC(Sender:TObject);
var AufScpt:TAufScript;
    arr:pdouble;
    pi,V:integer;
begin
  AufScpt:=Sender as TAufScript;
  arr:=GetMem(8*netw.NodeCount);
  netw.CalcDegreeCentrality(arr);
  V:=netw.NodeCount;
  AufScpt.writeln('ID      DC        Name');
  for pi:=0 to V-1 do
    begin
      AufScpt.writeln(Usf.left_adjust(IntToStr(pi),6,6)+'  '+FloatToResult(Arr[pi])+'  '+netw.Nodes[pi].name);
    end;
  FreeMem(arr,8*netw.NodeCount);
end;
procedure FuncCalcCC(Sender:TObject);
var AufScpt:TAufScript;
    arr:pdouble;
    pi,V:integer;
begin
  AufScpt:=Sender as TAufScript;
  arr:=GetMem(8*netw.NodeCount);
  try
    netw.CalcClosenessCentrality(arr);
    V:=netw.NodeCount;
    AufScpt.writeln('ID      CC        Name');
    for pi:=0 to V-1 do
      begin
        AufScpt.writeln(Usf.left_adjust(IntToStr(pi),6,6)+'  '+FloatToResult(Arr[pi])+'  '+netw.Nodes[pi].name);
      end;
  except
    AufScpt.send_error('???????????????????????????????????????');
  end;
  FreeMem(arr,8*netw.NodeCount);
end;
procedure FuncCalcIRCC(Sender:TObject);
var AufScpt:TAufScript;
    arr:pdouble;
    pi,V:integer;
begin
  AufScpt:=Sender as TAufScript;
  arr:=GetMem(8*netw.NodeCount);
  try
    netw.CalcInfluenceRangeClosenessCentrality(arr);
    V:=netw.NodeCount;
    AufScpt.writeln('ID      IRCC      Name');
    for pi:=0 to V-1 do
      begin
        AufScpt.writeln(Usf.left_adjust(IntToStr(pi),6,6)+'  '+FloatToResult(Arr[pi])+'  '+netw.Nodes[pi].name);
      end;
  except
    AufScpt.send_error('???????????????');
  end;
  FreeMem(arr,8*netw.NodeCount);
end;
procedure FuncCalcBC(Sender:TObject);
var AufScpt:TAufScript;
    arr:pdouble;
    pi,V:integer;
begin
  AufScpt:=Sender as TAufScript;
  arr:=GetMem(8*netw.NodeCount);

  netw.CalcBetweennessCentrality(arr);
  V:=netw.NodeCount;
  AufScpt.writeln('ID      BC        Name');
  for pi:=0 to V-1 do
    begin
      AufScpt.writeln(Usf.left_adjust(IntToStr(pi),6,6)+'  '+FloatToResult(Arr[pi])+'  '+netw.Nodes[pi].name);
    end;

  FreeMem(arr,8*netw.NodeCount);
end;



procedure FuncCalcMonoDist(Sender:TObject);
var AAuf:TAuf;
    AufScpt:TAufScript;
    arr:pdouble;
    pi,V:integer;
    nodeIndex:dword;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToDWord(1,nodeIndex) then exit;
  arr:=GetMem(8*netw.NodeCount);
  netw.DistanceTest(nodeIndex,arr);
  V:=netw.NodeCount;
  AufScpt.writeln('ID      Dist      Name');
  for pi:=0 to V-1 do
    begin
      AufScpt.writeln(Usf.left_adjust(IntToStr(pi),6,6)+'  '+FloatToResult(Arr[pi])+'  '+netw.Nodes[pi].name);
    end;
  FreeMem(arr,8*netw.NodeCount);
end;


procedure FuncLayoutRandomize(Sender:TObject);
var AufScpt:TAufScript;
    pi:integer;
begin
  AufScpt:=Sender as TAufScript;
  for pi:=0 to netw.NodeCount-1 do
    begin
      netw.Nodes[pi].pos.x:=random*800-400;
      netw.Nodes[pi].pos.y:=random*800-400;
    end;
  for pi:=0 to netw.ActorCount-1 do
    begin
      netw.Actors[pi].pos.x:=random*800-400;
      netw.Actors[pi].pos.y:=random*800-400;
    end;

  Form_Main.PaintBox_Net.Repaint;
end;
procedure FuncLayoutLoopOrd(Sender:TObject);
var AufScpt:TAufScript;
    p_i,V:integer;
begin
  AufScpt:=Sender as TAufScript;
  V:=netw.NodeCount;
  for p_i:=0 to V-1 do
    begin
      netw.Nodes[p_i].pos.x:=400*cos(2*System.PI*p_i/V);
      netw.Nodes[p_i].pos.y:=400*sin(2*System.PI*p_i/V);
    end;
  V:=netw.ActorCount;
  for p_i:=0 to V-1 do
    begin
      netw.Actors[p_i].pos.x:=600*cos(2*System.PI*p_i/V);
      netw.Actors[p_i].pos.y:=600*sin(2*System.PI*p_i/V);
    end;

  Form_Main.PaintBox_Net.Repaint;
end;
procedure FuncLayoutColor(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    p_i,V:integer;
    hue:dword;
    mode:byte;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToDWord(1,hue) then exit;
  mode:=0;
  if AAuf.ArgsCount>2 then case lowercase(AAuf.args[2]) of
    'calc':mode:=1;
    else mode:=0;
  end;

  V:=netw.NodeCount;
  for p_i:=0 to V-1 do
    begin
      with netw.Nodes[p_i] do
        begin
          case mode of
            0:Color:=HSVToColor(Group*hue mod 360,100,100);
            1:if CalcResult<>NA then Color:=HSVToColor(round(CalcResult*hue) mod 360,100,100)
              else Color:=clBlack;
          end;

        end;

    end;
  Form_Main.PaintBox_Net.Repaint;
end;
procedure FuncLayoutGeo(Sender:TObject);
var AufScpt:TAufScript;
    p_i,V:integer;
begin
  AufScpt:=Sender as TAufScript;
  V:=netw.NodeCount;
  for p_i:=0 to V-1 do with netw.Nodes[p_i] do
    begin
      pos.x:=latlong.x;
      pos.y:=latlong.y;
    end;
  V:=netw.ActorCount;
  for p_i:=0 to V-1 do with netw.Actors[p_i] do
    begin
      pos.x:=latlong.x;
      pos.y:=latlong.y;
    end;

  Form_Main.PaintBox_Net.Repaint;
end;
procedure FuncLayoutDraw(Sender:TObject);
begin
  Form_Main.PaintBox_Net.Repaint;
end;

procedure FuncProcEnding(Sender:TObject);
begin
  Form_Main.PaintBox_Net.Repaint;
  Application.ProcessMessages;
end;



{$R *.lfm}

{ TForm_Main }

procedure TForm_Main.FormCreate(Sender: TObject);
begin
  Randomize;
  Frame_AufScript1.AufGenerator;
  Frame_AufScript1.Auf.Script.add_func('net.clear',@FuncClear,'','????????????');
  Frame_AufScript1.Auf.Script.add_func('net.build.rand',@FuncBuildRand,'N,P','??????????????????');
  Frame_AufScript1.Auf.Script.add_func('net.indirect',@FuncIndirectGraphy,'','????????????/?????????');
  Frame_AufScript1.Auf.Script.add_func('net.indirectchk',@FuncIndirectWeightCheck,'','?????????????????????');
  Frame_AufScript1.Auf.Script.add_func('net.removemid',@FuncRemoveMidNode,'','???????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('net.len2weight',@FuncLengthToWeight,'','?????????????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('net.reverseweight',@FuncReverseWeight,'','????????????????????????');

  Frame_AufScript1.Auf.Script.add_func('net.complement',@FuncComplement,'','???????????????????????????1');
  Frame_AufScript1.Auf.Script.add_func('net.bipartite',@FuncBipartite,'','???????????????????????????????????????0');


  Frame_AufScript1.Auf.Script.add_func('node.add',@FuncAddNode,'name[,out,x,y]','????????????');
  Frame_AufScript1.Auf.Script.add_func('edge.add',@FuncAddEdge,'n1,n2[,out]','????????????');

  Frame_AufScript1.Auf.Script.add_func('node.addbyname',@FuncAddNodeByName,'name,x,y','????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('edge.addbyname',@FuncAddEdgeByName,'name1,name2','????????????????????????');

  Frame_AufScript1.Auf.Script.add_func('actor.add',@FuncAddActor,'name[,out,x,y]','???????????????');
  Frame_AufScript1.Auf.Script.add_func('actor.addbyname',@FuncAddActorByName,'name,x,y','???????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('actor.io.inp.json',@FuncImportActorFromGeoJson,'filename','??????GeoJson???????????????');
  Frame_AufScript1.Auf.Script.add_func('actor.updateedge',@FuncUpdateActorsEdge,'','?????????????????????????????????????????????????????????');

  Frame_AufScript1.Auf.Script.add_func('od.build.block',@FuncBuildBlockOD,'','???????????????????????????????????????OD');
  Frame_AufScript1.Auf.Script.add_func('od.build.rand',@FuncBuildRandomOD,'P','????????????OD');

  Frame_AufScript1.Auf.Script.add_func('od.io.inp.json',@FuncImportODsFromGeoJson,'filename','??????GeoJson??????OD');


  Frame_AufScript1.Auf.Script.add_func('actor.odtest',@FuncODTest,'actor1,actor2','????????????????????????????????????????????????????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('actor.odfreq',@FuncODFrequency,'','???????????????????????????????????????????????????????????????????????????');


  Frame_AufScript1.Auf.Script.add_func('io.out.adj',@FuncExportAdjCSV,'filename','??????????????????');
  Frame_AufScript1.Auf.Script.add_func('io.inp.adj',@FuncImportAdjCSV,'filename','??????????????????');
  Frame_AufScript1.Auf.Script.add_func('io.out.json',@FuncExportGeoJson,'filename','??????GeoJson');
  Frame_AufScript1.Auf.Script.add_func('io.inp.json',@FuncImportGeoJson,'filename','??????GeoJson');

  Frame_AufScript1.Auf.Script.add_func('io.data.export',@FuncDataListExport,'filename','????????????????????????filename');


  Frame_AufScript1.Auf.Script.add_func('calc.den',@FuncCalcDensity,'','??????????????????');
  Frame_AufScript1.Auf.Script.add_func('calc.diam',@FuncCalcDiam,'','??????????????????');
  Frame_AufScript1.Auf.Script.add_func('calc.rad',@FuncCalcRad,'','??????????????????');
  Frame_AufScript1.Auf.Script.add_func('calc.wiener',@FuncCalcWiener,'','????????????Wiener??????');

  Frame_AufScript1.Auf.Script.add_func('calc.cci',@FuncCalcClusteringCoefficient,'','??????????????????');
  Frame_AufScript1.Auf.Script.add_func('calc.kappa',@FuncCalcKappa,'','???????????????');

  Frame_AufScript1.Auf.Script.add_func('calc.dc',@FuncCalcDC,'','???????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('calc.cc',@FuncCalcCC,'','???????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('calc.ircc',@FuncCalcIRCC,'','????????????????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('calc.bc',@FuncCalcBC,'','???????????????????????????');

  Frame_AufScript1.Auf.Script.add_func('calc.monodist',@FuncCalcMonoDist,'node','??????????????????????????????????????????');

  Frame_AufScript1.Auf.Script.add_func('lay.rand',@FuncLayoutRandomize,'','????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('lay.loop',@FuncLayoutLoopOrd,'','???????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('lay.geo',@FuncLayoutGeo,'','?????????????????????????????????');

  Frame_AufScript1.Auf.Script.add_func('lay.color.hue',@FuncLayoutColor,'','????????????????????????');
  Frame_AufScript1.Auf.Script.add_func('lay.draw',@FuncLayoutDraw,'','???????????????');


  //Frame_AufScript1.Auf.Script.Func_process.ending:=@FuncProcEnding;//AufFrame????????????????????????????????????

  netw:=TTC2_Network.Create;
end;

procedure TForm_Main.Frame_AufScript1Resize(Sender: TObject);
begin
  Frame_AufScript1.FrameResize(Frame_AufScript1);
end;

procedure TForm_Main.PaintBox_NetPaint(Sender: TObject);
var PB:TPaintBox;
    pi:integer;
    W,H,L,R,T,B,WW,HH:{integer}double;
    NodeLabel,EdgeLabel:integer;
    n1,n2,a1,a2:TPoint;
    show_arrow,node_label,edge_label:boolean;
    edge_width,edge_display_value,node_size:double;
    edge_display_precision:smallint;
    node_size_value:qword;

begin
  PB:=Sender as TPaintBox;
  if not assigned(netw) then exit;
  if (netw.NodeCount=0) and (netw.ActorCount=0) then exit;

  show_arrow:=CheckBox_ShowArrow.Checked;
  node_label:=CheckBox_NodeLabel.Checked;
  edge_label:=CheckBox_EdgeLabel.Checked;

  edge_width:=FloatSpinEdit_EdgeWidth.Value;
  node_size:=FloatSpinEdit_NodeSize.Value;

  NodeLabel:=Self.RadioGroup_NodeLabel.ItemIndex;
  EdgeLabel:=Self.RadioGroup_EdgeLabel.ItemIndex;
  W:=PB.Width;
  H:=PB.Height;

  netw.GetMaxMinXY(L,T,R,B);

  FloatSpinEditEx_Top.Value:=T;
  FloatSpinEditEx_Bottom.Value:=B;
  FloatSpinEditEx_Left.Value:=L;
  FloatSpinEditEx_Right.Value:=R;
  WW:=(R-L)*0.05;
  HH:=(B-T)*0.05;
  if WW*HH=0 then exit;
  T:=T-HH;
  B:=B+HH;
  L:=L-WW;
  R:=R+WW;

  //?????????????????????????????????
  PB.Canvas.Brush.Color:=clBlack;
  for pi:=0 to netw.NodeCount-1 do
    with netw.Nodes[pi] do
      begin
        paint_pos.x:=round((pos.x-L)/(R-L)*W);
        paint_pos.y:=round((pos.y-T)/(B-T)*H);
      end;
  for pi:=0 to netw.ActorCount-1 do
    with (netw.Actors[pi]) do
      begin
        paint_pos.x:=round((pos.x-L)/(R-L)*W);
        paint_pos.y:=round((pos.y-T)/(B-T)*H);
      end;

  //????????????
  IF CheckBox_ShowEdges.Checked THEN BEGIN
    for pi:=0 to netw.EdgeCount-1 do
      with netw.Edges[pi] do
        begin
          //???????????????????????????
          case EdgeLabel of
            3:begin edge_display_value:=frequent;edge_display_precision:=2;end;
            2:begin edge_display_value:=weight;edge_display_precision:=1;end;
            1:begin edge_display_value:=id;edge_display_precision:=0;end;
            else begin edge_display_value:=0;edge_display_precision:=-1;end;
          end;
          GetArrowPoint(nodes[0].paint_pos,nodes[1].paint_pos,6,n1,n2,a1,a2);
          //??????
          PB.Canvas.Pen.Color:=clBlack;
          PB.Canvas.Pen.Width:=trunc(edge_width*edge_display_value)+1;
          PB.Canvas.Line(n1,n2);
          //?????????
          if show_arrow then begin
            PB.Canvas.Brush.Style:=bsSolid;
            PB.Canvas.Brush.Color:=clBlack;
            //PB.Canvas.Pen.Color:=clBlack;
            //PB.Canvas.Pen.Color:=clBlack;
            PB.Canvas.Polygon([n2,a1,a2]);
          end;
          //??????
          IF edge_label THEN BEGIN
            PB.Canvas.Brush.Style:=bsClear;
            PB.Canvas.Font.Size:=10;
            PB.Canvas.Font.Color:=clBlack;
            if edge_display_precision>=0 then
              PB.Canvas.TextOut(
                (nodes[0].paint_pos.x+nodes[1].paint_pos.x) div 2,
                (nodes[0].paint_pos.y+nodes[1].paint_pos.y) div 2,
                FloatToStrF(edge_display_value,ffFixed,1,edge_display_precision)
              );
          END;
        end;
  END;

  //??????OD
  IF CheckBox_ShowODs.Checked THEN BEGIN
    for pi:=0 to netw.ODCount-1 do
      with netw.ODs[pi] do
        begin
          //???????????????????????????
          GetArrowPoint(actors[0].paint_pos,actors[1].paint_pos,6,n1,n2,a1,a2);
          //??????
          PB.Canvas.Pen.Color:=clBlack;
          PB.Canvas.Pen.Width:=1;
          PB.Canvas.Line(n1,n2);
          //?????????
          if show_arrow then begin
            PB.Canvas.Brush.Style:=bsSolid;
            PB.Canvas.Brush.Color:=clBlack;
            //PB.Canvas.Pen.Color:=clBlack;
            //PB.Canvas.Pen.Color:=clBlack;
            PB.Canvas.Polygon([n2,a1,a2]);
          end;
        end;
  END;

  //??????????????????
  IF CheckBox_ShowNodes.Checked THEN BEGIN
    IF node_label THEN BEGIN
      PB.Canvas.Brush.Style:=bsClear;
      PB.Canvas.Font.Color:=clRed;
      PB.Canvas.Font.Size:=10;
      for pi:=0 to netw.NodeCount-1 do
        with netw.Nodes[pi] do
          begin
            case NodeLabel of
              4:PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,FloatToStrF(CalcResult,ffFixed,1,1));
              3:PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,IntToStr(Group));
              2:PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,Utf8toWinCP(name));
              1:PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,IntToStr(id));
              else ;
            end;
          end;
    END;
  END;

  //??????????????????
  IF CheckBox_ShowNodes.Checked THEN BEGIN
    PB.Canvas.Brush.Style:=bsSolid;
    PB.Canvas.Brush.Color:=clRed;
    PB.Canvas.Pen.Width:=1;
    PB.Canvas.Pen.Color:=clBlack;
    for pi:=0 to netw.NodeCount-1 do
      with netw.Nodes[pi] do
        begin
          PB.Canvas.Brush.Color:=Color;
          if NodeLabel=4 then node_size_value:=trunc(CalcResult*node_size/2) else node_size_value:=5;
          PB.Canvas.Rectangle(
            paint_pos.x-node_size_value,
            paint_pos.y-node_size_value,
            paint_pos.x+node_size_value,
            paint_pos.y+node_size_value
          );
          //PB.Canvas.Chord(paint_pos.x-5,paint_pos.y-5,paint_pos.x+5,paint_pos.y+5,0,360*16);
        end;
  END;

  //?????????????????????
  IF CheckBox_ShowActors.Checked THEN BEGIN
    IF node_label THEN BEGIN
      PB.Canvas.Brush.Style:=bsClear;
      PB.Canvas.Font.Color:=clBlue;
      PB.Canvas.Font.Size:=8;
      for pi:=0 to netw.ActorCount-1 do
        with netw.Actors[pi] do
          PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,IntToStr(id));
    END;
  END;

  //?????????????????????
  IF CheckBox_ShowActors.Checked THEN BEGIN
    PB.Canvas.Brush.Style:=bsSolid;
    PB.Canvas.Pen.Width:=1;
    PB.Canvas.Pen.Color:=clBlack;
    for pi:=0 to netw.ActorCount-1 do
      with netw.Actors[pi] do
        begin
          PB.Canvas.Brush.Color:=clBlue;
          //if NodeLabel=4 then node_size_value:=trunc(CalcResult*node_size/2) else node_size_value:=5;
          node_size_value:=3;
          PB.Canvas.Chord(
            paint_pos.x-node_size_value,
            paint_pos.y-node_size_value,
            paint_pos.x+node_size_value,
            paint_pos.y+node_size_value,
          0,360*16);
        end;
  END;
end;

procedure TForm_Main.RadioGroup_EdgeLabelClick(Sender: TObject);
begin
  Self.Repaint;
end;

procedure TForm_Main.RadioGroup_NodeLabelClick(Sender: TObject);
begin
  Self.Repaint;
end;

procedure TForm_Main.StringGrid_DV_ActorEnter(Sender: TObject);
var pi:integer;
    SG:TStringGrid;
begin
  SG:=Sender as TStringGrid;
  SG.Clear;
  SG.ColCount:=6;
  SG.Cells[0,0]:='ID';
  SG.Cells[1,0]:='Name';
  SG.Cells[2,0]:='Edge';
  SG.Cells[3,0]:='dist';
  SG.Cells[4,0]:='n_dist_1';
  SG.Cells[5,0]:='n_dist_2';
  SG.RowCount:=netw.ActorCount+1;
  for pi:=0 to netw.ActorCount-1 do with netw.Actors[pi] do
    begin
      SG.Cells[0,pi+1]:=IntToStr(id);
      SG.Cells[1,pi+1]:=name;
      if edge<>nil then SG.Cells[2,pi+1]:=IntToStr(edge.id);
      SG.Cells[3,pi+1]:=FloatToStrF(distance,ffFixed,4,6);
      SG.Cells[4,pi+1]:=FloatToStrF(node_distance[0],ffFixed,4,6);
      SG.Cells[5,pi+1]:=FloatToStrF(node_distance[1],ffFixed,4,6);
    end;

end;

procedure TForm_Main.StringGrid_DV_EdgeEnter(Sender: TObject);
var pi:integer;
    SG:TStringGrid;
begin
  SG:=Sender as TStringGrid;
  SG.Clear;
  SG.ColCount:=5;
  SG.Cells[0,0]:='ID';
  SG.Cells[1,0]:='??????';
  SG.Cells[2,0]:='node_1';
  SG.Cells[3,0]:='node_2';
  SG.Cells[4,0]:='??????';
  SG.RowCount:=netw.EdgeCount+1;
  for pi:=0 to netw.EdgeCount-1 do with netw.Edges[pi] do
    begin
      SG.Cells[0,pi+1]:=IntToStr(id);
      SG.Cells[1,pi+1]:=FloatToStrF(weight,ffFixed,4,6);
      if nodes[0]<>nil then SG.Cells[2,pi+1]:=IntToStr(nodes[0].id);
      if nodes[1]<>nil then SG.Cells[3,pi+1]:=IntToStr(nodes[1].id);
      SG.Cells[4,pi+1]:=FloatToStrF(frequent,ffFixed,4,6);
    end;

end;

procedure TForm_Main.StringGrid_DV_NodeEnter(Sender: TObject);
var pi:integer;
    SG:TStringGrid;
begin
  SG:=Sender as TStringGrid;
  SG.Clear;
  SG.ColCount:=6;
  SG.Cells[0,0]:='ID';
  SG.Cells[1,0]:='Name';
  SG.Cells[2,0]:='group';
  SG.Cells[3,0]:='result';
  SG.Cells[4,0]:='geo_x';
  SG.Cells[5,0]:='geo_y';
  SG.RowCount:=netw.NodeCount+1;
  for pi:=0 to netw.NodeCount-1 do with netw.Nodes[pi] do
    begin
      SG.Cells[0,pi+1]:=IntToStr(id);
      SG.Cells[1,pi+1]:=name;
      SG.Cells[2,pi+1]:=IntToStr(Group);
      SG.Cells[3,pi+1]:=FloatToStrF(CalcResult,ffFixed,4,6);
      SG.Cells[4,pi+1]:=FloatToStrF(latlong.x,ffFixed,7,10);
      SG.Cells[5,pi+1]:=FloatToStrF(latlong.y,ffFixed,7,10);
    end;

end;

procedure TForm_Main.StringGrid_DV_ODEnter(Sender: TObject);
var pi:integer;
    SG:TStringGrid;
begin
  SG:=Sender as TStringGrid;
  SG.Clear;
  SG.ColCount:=5;
  SG.Cells[0,0]:='ID';
  SG.Cells[1,0]:='actor_1';
  SG.Cells[2,0]:='actor_2';
  SG.Cells[3,0]:='dist';
  SG.Cells[4,0]:='FID';
  SG.RowCount:=netw.ODCount+1;
  for pi:=0 to netw.ODCount-1 do with netw.ODs[pi] do
    begin
      SG.Cells[0,pi+1]:=IntToStr(id);
      if actors[0]<>nil then SG.Cells[1,pi+1]:=IntToStr(actors[0].id);
      if actors[1]<>nil then SG.Cells[2,pi+1]:=IntToStr(actors[1].id);
      SG.Cells[3,pi+1]:=FloatToStrF(distance,ffFixed,4,6);
      SG.Cells[4,pi+1]:=IntToStr(fid);
    end;

end;

procedure TForm_Main.TrackBar_AlphaChange(Sender: TObject);
begin
  Self.AlphaBlendValue:=(Sender as TTrackBar).Position;
end;

procedure TForm_Main.TrackBar_ZoneChange(Sender: TObject);
begin
  with Sender as TTrackBar do
    begin
      PaintBox_Net.Width:=ScrollBox_PaintBox.Width*Position div 10;
      PaintBox_Net.Height:=ScrollBox_PaintBox.Height*Position div 10;
    end;
end;

procedure TForm_Main.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  netw.Free;
end;

procedure TForm_Main.CheckBox_ShowArrowClick(Sender: TObject);
begin
  Self.Repaint;
end;

procedure TForm_Main.FloatSpinEdit_EdgeWidthEditingDone(Sender: TObject);
begin
  Self.Repaint;
end;

procedure TForm_Main.FloatSpinEdit_NodeSizeEditingDone(Sender: TObject);
begin
  Self.Repaint;
end;

procedure TForm_Main.CheckBox_EdgeLabelClick(Sender: TObject);
begin
  Self.Repaint;
end;

procedure TForm_Main.Button_Export_SGClick(Sender: TObject);
var filename:string;
begin
  filename:=Edit_ExportName.Caption;
  try
    StringGrid_DV_Actor.SaveToCSVFile(filename+'_actor.csv');
    StringGrid_DV_OD.SaveToCSVFile(filename+'_od.csv');
    StringGrid_DV_Node.SaveToCSVFile(filename+'_node.csv');
    StringGrid_DV_Edge.SaveToCSVFile(filename+'_edge.csv');
    ShowMessage('???????????????');
  except
    ShowMessage('???????????????');
  end;
end;

procedure TForm_Main.CheckBox_NodeLabelClick(Sender: TObject);
begin
  Self.Repaint;
end;

end.

