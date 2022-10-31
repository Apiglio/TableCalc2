unit tc2_mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, Spin, Grids, Menus, LazUTF8, SpinEx, Apiglio_Useful,
  aufscript_frame, auf_ram_var, tc2_network, Types;

const NA:double=$7fffffffffffffff;

type

  { TForm_Main }

  TForm_Main = class(TForm)
    Button_Export_SG: TButton;
    CheckBox_ShowODs: TCheckBox;
    CheckBox_ShowNodes: TCheckBox;
    CheckBox_ShowEdgeLabel: TCheckBox;
    CheckBox_ShowNodeLabel: TCheckBox;
    CheckBox_ShowActorLabel: TCheckBox;
    CheckBox_ShowEdgeArrow: TCheckBox;
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
    MainMenu1: TMainMenu;
    MenuItem_Layout_Geo: TMenuItem;
    MenuItem_Layout_Loop: TMenuItem;
    MenuItem_Layout_Random: TMenuItem;
    MenuItem_Layout: TMenuItem;
    MenuItem_Network_disweight: TMenuItem;
    MenuItem_Network_WeightReverse: TMenuItem;
    MenuItem_Network_indirect: TMenuItem;
    MenuItem_Network_div02: TMenuItem;
    MenuItem_Network_ExportGeoJSON: TMenuItem;
    MenuItem_Network_ExportEdgelist: TMenuItem;
    MenuItem_Network_ExportAdjacent: TMenuItem;
    MenuItem_Network_ImportGeoJSON: TMenuItem;
    MenuItem_Network_ImportEdgelist: TMenuItem;
    MenuItem_Network_ImportAdjacent: TMenuItem;
    MenuItem_Network_Export: TMenuItem;
    MenuItem_Network_Import: TMenuItem;
    MenuItem_Network_div01: TMenuItem;
    MenuItem_Calc_CCI: TMenuItem;
    MenuItem_Calc_Wiener: TMenuItem;
    MenuItem_Calc_radius: TMenuItem;
    MenuItem_Calc_diameter: TMenuItem;
    MenuItem_Calc_density: TMenuItem;
    MenuItem_Calc_General: TMenuItem;
    MenuItem_Calc_IRCC: TMenuItem;
    MenuItem_Calc_BC: TMenuItem;
    MenuItem_Calc_CC: TMenuItem;
    MenuItem_Calc_DC: TMenuItem;
    MenuItem_Calc_Centralities: TMenuItem;
    MenuItem_Network_genWhat: TMenuItem;
    MenuItem_Network_genRandom: TMenuItem;
    MenuItem_Network: TMenuItem;
    MenuItem_Calc: TMenuItem;
    PageControl_DataView: TPageControl;
    ScrollBox_PaintOption: TScrollBox;
    ScrollBox_ActorOption: TScrollBox;
    ScrollBox_ODOption: TScrollBox;
    ScrollBox_PaintBox: TScrollBox;
    ScrollBox_LayoutOption: TScrollBox;
    ScrollBox_EdgeOption: TScrollBox;
    ScrollBox_NodeOption: TScrollBox;
    PageControl1: TPageControl;
    PaintBox_Net: TPaintBox;
    RadioGroup_EdgeLabelType: TRadioGroup;
    RadioGroup_NodeLabelType: TRadioGroup;
    Splitter: TSplitter;
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
    procedure Button_runClick(Sender: TObject);
    procedure CheckBox_ShowActorLabelClick(Sender: TObject);
    procedure CheckBox_ShowEdgeLabelClick(Sender: TObject);
    procedure CheckBox_ShowNodeLabelClick(Sender: TObject);
    procedure CheckBox_ShowActorsClick(Sender: TObject);
    procedure CheckBox_ShowEdgeArrowClick(Sender: TObject);
    procedure CheckBox_ShowEdgesClick(Sender: TObject);
    procedure CheckBox_ShowNodesClick(Sender: TObject);
    procedure CheckBox_ShowODsClick(Sender: TObject);
    procedure FloatSpinEdit_EdgeWidthEditingDone(Sender: TObject);
    procedure FloatSpinEdit_NodeSizeEditingDone(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Frame_AufScript1Resize(Sender: TObject);
    procedure MenuItem_Calc_BCClick(Sender: TObject);
    procedure MenuItem_Calc_CCClick(Sender: TObject);
    procedure MenuItem_Calc_CCIClick(Sender: TObject);
    procedure MenuItem_Calc_DCClick(Sender: TObject);
    procedure MenuItem_Calc_densityClick(Sender: TObject);
    procedure MenuItem_Calc_diameterClick(Sender: TObject);
    procedure MenuItem_Calc_IRCCClick(Sender: TObject);
    procedure MenuItem_Calc_radiusClick(Sender: TObject);
    procedure MenuItem_Calc_WienerClick(Sender: TObject);
    procedure MenuItem_Layout_GeoClick(Sender: TObject);
    procedure MenuItem_Layout_LoopClick(Sender: TObject);
    procedure MenuItem_Layout_RandomClick(Sender: TObject);
    procedure MenuItem_Network_ExportAdjacentClick(Sender: TObject);
    procedure MenuItem_Network_ExportEdgelistClick(Sender: TObject);
    procedure MenuItem_Network_ExportGeoJSONClick(Sender: TObject);
    procedure MenuItem_Network_genRandomClick(Sender: TObject);
    procedure MenuItem_Network_ImportAdjacentClick(Sender: TObject);
    procedure MenuItem_Network_ImportEdgelistClick(Sender: TObject);
    procedure MenuItem_Network_ImportGeoJSONClick(Sender: TObject);
    procedure PaintBox_NetPaint(Sender: TObject);
    procedure RadioGroup_EdgeLabelTypeClick(Sender: TObject);
    procedure RadioGroup_NodeLabelTypeClick(Sender: TObject);
    procedure StringGrid_DV_ActorEnter(Sender: TObject);
    procedure StringGrid_DV_EdgeEnter(Sender: TObject);
    procedure StringGrid_DV_NodeEnter(Sender: TObject);
    procedure StringGrid_DV_ODEnter(Sender: TObject);
    procedure TrackBar_AlphaChange(Sender: TObject);
    procedure TrackBar_ZoneChange(Sender: TObject);
  private

  public
    procedure UpdatePaintOptionToForm(a_paintOption:TPaintOption);

  end;

var
  Form_Main: TForm_Main;
  netw:TTC2_Network;
  paintOption:TPaintOption;
  MenuRunError,EndingMessage:string;
  GlobalResult:Double;

implementation
uses tc2_dialog;


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
  if arv.VarType=ARV_Raw then AufScpt.writeln('新建节点#'+IntToStr(index))
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
  if arv.VarType=ARV_Raw then AufScpt.writeln('新建行动者#'+IntToStr(index))
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
  if arv.VarType=ARV_Raw then AufScpt.writeln('新建连接#'+IntToStr(index))
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
      AufScpt.writeln('新建节点"'+nodename+'"。');
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
  else AufScpt.writeln('节点"'+nodename+'"已存在。');
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
      AufScpt.writeln('新建行动者"'+actorname+'"。');
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
  else AufScpt.writeln('节点"'+actorname+'"已存在。');
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
  if (na=nil) or (nb=nil) then AufScpt.send_error('未找到指定名称的节点。')
  else
    begin
      netw.AddEdge(na,nb).weight:=weight;
      AufScpt.writeln('连接创建成功。');
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
        AufScpt.writeln('导出成功。');
      except
        AufScpt.writeln('导出失败。');
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
  AufScpt.writeln('随机OD矩阵已创建。');
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
  AufScpt.writeln('最短路径距离为：'+FloatToStrF(ODTest(Actors[a1],Actors[a2]),ffFixed,3,10));
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
  AufScpt.writeln('网络已清空。');
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
  AufScpt.writeln('随机网络已创建。');
end;
procedure FuncIndirectGraphy(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.IndirectGraphy;
  AufScpt.writeln('网络已无向图化。');
end;
procedure FuncIndirectWeightCheck(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.IndirectWeightCheck(Sender,@AufScptWritelnFunc);
  AufScpt.writeln('网络无向图化权重修正完成。');
end;
procedure FuncRemoveMidNode(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.RemoveMidNode;
  AufScpt.writeln('无意义过境点已删除。');
end;
procedure FuncLengthToWeight(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.SpatialEdgeWeight;
  AufScpt.writeln('权重已修改为当前布局距离。');
end;
procedure FuncReverseWeight(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.ReverseWeight;
  AufScpt.writeln('权重已取倒数。');
end;
procedure FuncComplement(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.ComplementGraphy(true);
  AufScpt.writeln('已补图化。');
end;
procedure FuncBipartite(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  netw.CalcBipartiteGraphy;
  AufScpt.writeln('已尝试进行二部图划分，结果保存在分组信息中。');
end;





procedure FuncCalcDensity(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  GlobalResult:=netw.CalcDensity;
  AufScpt.writeln('网络密度 D='+FloatToResult(GlobalResult));
end;
procedure FuncCalcDiam(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  GlobalResult:=netw.CalcDiameter;
  AufScpt.writeln('网络直径 diam='+FloatToResult(GlobalResult));
end;
procedure FuncCalcRad(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  GlobalResult:=netw.CalcRadius;
  AufScpt.writeln('网络半径 rad='+FloatToResult(GlobalResult));
end;
procedure FuncCalcWiener(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  try
    GlobalResult:=netw.CalcWiener;
    AufScpt.writeln('网络Wiener指数 W='+FloatToResult(GlobalResult));
  except
    GlobalResult:=NA;
    AufScpt.send_error('Wiener指数只适用于连通图。');
  end;
end;
procedure FuncCalcClusteringCoefficient(Sender:TObject);
var AufScpt:TAufScript;
    arr:pdouble;
    pi:integer;
begin
  AufScpt:=Sender as TAufScript;
  arr:=GetMem(8*netw.NodeCount);
  GlobalResult:=netw.CalcClusteringCoefficient(Arr);
  AufScpt.writeln('全局聚类系数 C='+FloatToResult(GlobalResult));
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
  GlobalResult:=netw.CalcConnectedComponent(Arr);
  AufScpt.writeln('连通分量数量 K='+FloatToResult(GlobalResult));
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
    AufScpt.send_error('接近中心度只适用于连通图。');
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
    AufScpt.send_error('未知错误。');
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
  if EndingMessage<>'' then ShowMessage(EndingMessage+FloatToResult(GlobalResult));
  EndingMessage:='';
end;

procedure FuncProcRaise(Sender:TObject);
begin
  ShowMessage(MenuRunError);
end;

{$R *.lfm}

{ TForm_Main }

procedure TForm_Main.FormCreate(Sender: TObject);
begin
  Randomize;
  Frame_AufScript1.AufGenerator;
  Frame_AufScript1.Auf.Script.add_func('net.clear',@FuncClear,'','清空网络');
  Frame_AufScript1.Auf.Script.add_func('net.build.rand',@FuncBuildRand,'N,P','创建随机网络');
  Frame_AufScript1.Auf.Script.add_func('net.indirect',@FuncIndirectGraphy,'','无向图化/双向化');
  Frame_AufScript1.Auf.Script.add_func('net.indirectchk',@FuncIndirectWeightCheck,'','双向化权重修正');
  Frame_AufScript1.Auf.Script.add_func('net.removemid',@FuncRemoveMidNode,'','删除无意义的过境点');
  Frame_AufScript1.Auf.Script.add_func('net.len2weight',@FuncLengthToWeight,'','将当前布局距离作为权重');
  Frame_AufScript1.Auf.Script.add_func('net.reverseweight',@FuncReverseWeight,'','将网络权重取倒数');

  Frame_AufScript1.Auf.Script.add_func('net.complement',@FuncComplement,'','转换为补图，权重为1');
  Frame_AufScript1.Auf.Script.add_func('net.bipartite',@FuncBipartite,'','二部图检验，若为离散点则为0');


  Frame_AufScript1.Auf.Script.add_func('node.add',@FuncAddNode,'name[,out,x,y]','增加节点');
  Frame_AufScript1.Auf.Script.add_func('edge.add',@FuncAddEdge,'n1,n2[,out]','增加连接');

  Frame_AufScript1.Auf.Script.add_func('node.addbyname',@FuncAddNodeByName,'name,x,y','根据名称增加节点');
  Frame_AufScript1.Auf.Script.add_func('edge.addbyname',@FuncAddEdgeByName,'name1,name2','根据名称增加连接');

  Frame_AufScript1.Auf.Script.add_func('actor.add',@FuncAddActor,'name[,out,x,y]','增加行动者');
  Frame_AufScript1.Auf.Script.add_func('actor.addbyname',@FuncAddActorByName,'name,x,y','根据名称增加行动者');
  Frame_AufScript1.Auf.Script.add_func('actor.io.inp.json',@FuncImportActorFromGeoJson,'filename','导入GeoJson中的行动者');
  Frame_AufScript1.Auf.Script.add_func('actor.updateedge',@FuncUpdateActorsEdge,'','根据地理位置查找每一个行动者的最近边线');

  Frame_AufScript1.Auf.Script.add_func('od.build.block',@FuncBuildBlockOD,'','在每两个行动者之间创建双向OD');
  Frame_AufScript1.Auf.Script.add_func('od.build.rand',@FuncBuildRandomOD,'P','创建随机OD');

  Frame_AufScript1.Auf.Script.add_func('od.io.inp.json',@FuncImportODsFromGeoJson,'filename','导入GeoJson中的OD');


  Frame_AufScript1.Auf.Script.add_func('actor.odtest',@FuncODTest,'actor1,actor2','计算两个行动者之间的最短网络路径，以此修改流量图');
  Frame_AufScript1.Auf.Script.add_func('actor.odfreq',@FuncODFrequency,'','计算每两个行动者之间的最短网络路径，以此修改流量图');


  Frame_AufScript1.Auf.Script.add_func('io.out.adj',@FuncExportAdjCSV,'filename','输出邻接矩阵');
  Frame_AufScript1.Auf.Script.add_func('io.inp.adj',@FuncImportAdjCSV,'filename','导入邻接矩阵');
  Frame_AufScript1.Auf.Script.add_func('io.out.json',@FuncExportGeoJson,'filename','导出GeoJson');
  Frame_AufScript1.Auf.Script.add_func('io.inp.json',@FuncImportGeoJson,'filename','导入GeoJson');

  Frame_AufScript1.Auf.Script.add_func('io.data.export',@FuncDataListExport,'filename','将数据表格导出到filename');


  Frame_AufScript1.Auf.Script.add_func('calc.den',@FuncCalcDensity,'','输出网络密度');
  Frame_AufScript1.Auf.Script.add_func('calc.diam',@FuncCalcDiam,'','输出网络直径');
  Frame_AufScript1.Auf.Script.add_func('calc.rad',@FuncCalcRad,'','输出网络半径');
  Frame_AufScript1.Auf.Script.add_func('calc.wiener',@FuncCalcWiener,'','输出网络Wiener指数');

  Frame_AufScript1.Auf.Script.add_func('calc.cci',@FuncCalcClusteringCoefficient,'','输出聚类系数');
  Frame_AufScript1.Auf.Script.add_func('calc.kappa',@FuncCalcKappa,'','输出分离集');

  Frame_AufScript1.Auf.Script.add_func('calc.dc',@FuncCalcDC,'','输出节点点度中心度');
  Frame_AufScript1.Auf.Script.add_func('calc.cc',@FuncCalcCC,'','输出节点接近中心度');
  Frame_AufScript1.Auf.Script.add_func('calc.ircc',@FuncCalcIRCC,'','输出节点非连通接近中心度');
  Frame_AufScript1.Auf.Script.add_func('calc.bc',@FuncCalcBC,'','输出节点中介中心度');

  Frame_AufScript1.Auf.Script.add_func('calc.monodist',@FuncCalcMonoDist,'node','输出从某节点到其他节点的距离');

  Frame_AufScript1.Auf.Script.add_func('lay.rand',@FuncLayoutRandomize,'','随机打乱节点位置');
  Frame_AufScript1.Auf.Script.add_func('lay.loop',@FuncLayoutLoopOrd,'','按顺序排列节点位置');
  Frame_AufScript1.Auf.Script.add_func('lay.geo',@FuncLayoutGeo,'','按地理坐标排列节点位置');

  Frame_AufScript1.Auf.Script.add_func('lay.color.hue',@FuncLayoutColor,'','色相差额分组着色');
  Frame_AufScript1.Auf.Script.add_func('lay.draw',@FuncLayoutDraw,'','更新绘图区');

  Frame_AufScript1.Auf.Script.Func_process.OnRaise:=@FuncProcRaise;
  Frame_AufScript1.Auf.Script.PSW.run_parameter.error_raise:=true;

  Frame_AufScript1.OnRunEnding:=@FuncProcEnding;

  netw:=TTC2_Network.Create;
  paintOption.Node.Shown:=true;
  paintOption.Node.SizeOption.scale:=0.5;
  paintOption.Node.LabelOption.Enabled:=false;
  paintOption.Node.LabelOption.LabelType:=ltnNone;

  paintOption.Edge.Shown:=true;
  paintOption.Edge.ShowArrow:=false;
  paintOption.Edge.WidthOption.scale:=0.5;
  paintOption.Edge.LabelOption.Enabled:=false;
  paintOption.Edge.LabelOption.LabelType:=lteNone;

  paintOption.Actor.Shown:=false;
  paintOption.Actor.LabelOption.Enabled:=false;

  paintOption.OD.Shown:=false;
  paintOption.OD.LabelOption.Enabled:=false;


end;

procedure TForm_Main.Frame_AufScript1Resize(Sender: TObject);
begin
  Frame_AufScript1.FrameResize(Frame_AufScript1);
end;

procedure TForm_Main.MenuItem_Calc_BCClick(Sender: TObject);
begin
  paintOption.Node.LabelOption.LabelType:=ltnResult;
  paintOption.Node.SizeOption.scale:=2.0;
  UpdatePaintOptionToForm(paintOption);
  MenuRunError:='计算中介中心度错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('calc.bc');
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.draw');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Calc_CCClick(Sender: TObject);
begin
  paintOption.Node.LabelOption.LabelType:=ltnResult;
  paintOption.Node.SizeOption.scale:=2.0;
  UpdatePaintOptionToForm(paintOption);
  MenuRunError:='计算接近中心度错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('calc.cc');
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.draw');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Calc_CCIClick(Sender: TObject);
begin
  MenuRunError:='计算聚集系数错误。';
  EndingMessage:=('全局聚集系数 CCI= ');
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('calc.cci');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Calc_DCClick(Sender: TObject);
begin
  paintOption.Node.LabelOption.LabelType:=ltnResult;
  paintOption.Node.SizeOption.scale:=2.0;
  UpdatePaintOptionToForm(paintOption);
  MenuRunError:='计算点度中心度错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('calc.dc');
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.draw');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Calc_densityClick(Sender: TObject);
begin
  MenuRunError:='计算网络密度错误。';
  EndingMessage:=('网络密度 density= ');
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('calc.den');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Calc_diameterClick(Sender: TObject);
begin
  MenuRunError:='计算网络直径错误。';
  EndingMessage:=('网络直径 diam= ');
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('calc.diam');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Calc_IRCCClick(Sender: TObject);
begin
  paintOption.Node.LabelOption.LabelType:=ltnResult;
  paintOption.Node.SizeOption.scale:=2.0;
  UpdatePaintOptionToForm(paintOption);
  MenuRunError:='计算非连通接近中心度错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('calc.ircc');
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.draw');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Calc_radiusClick(Sender: TObject);
begin
  MenuRunError:='计算网络半径错误。';
  EndingMessage:=('网络半径 rad= ');
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('calc.rad');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Calc_WienerClick(Sender: TObject);
begin
  MenuRunError:='计算Wiener指数错误。';
  EndingMessage:=('Wiener指数 W= ');
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('calc.wiener');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Layout_GeoClick(Sender: TObject);
begin
  MenuRunError:='地理布局错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.geo');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Layout_LoopClick(Sender: TObject);
begin
  MenuRunError:='环形布局错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.loop');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Layout_RandomClick(Sender: TObject);
begin
  MenuRunError:='随机布局错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.rand');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Network_ExportAdjacentClick(Sender: TObject);
begin
  Dialog_TC2.Call('导出领接矩阵',['文件路径'],[]);
  MenuRunError:='导出领接矩阵错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('io.out.adj "'+Dialog_TC2.Values[0]+'"');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Network_ExportEdgelistClick(Sender: TObject);
begin
  //
end;

procedure TForm_Main.MenuItem_Network_ExportGeoJSONClick(Sender: TObject);
begin
  Dialog_TC2.Call('导出GeoJSON',['文件路径'],[]);
  MenuRunError:='导出GeoJSON错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('io.out.json "'+Dialog_TC2.Values[0]+'"');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Network_genRandomClick(Sender: TObject);
begin
  Dialog_TC2.Call('创建随机网络',['节点数','连接概率'],[]);
  MenuRunError:='创建随机网络错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('net.clear');
  Frame_AufScript1.Memo_cmd.Lines.Add('net.build.rand '+Dialog_TC2.Values[0]+' '+Dialog_TC2.Values[1]);
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.loop');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Network_ImportAdjacentClick(Sender: TObject);
begin
  Dialog_TC2.Call('导入领接矩阵',['文件路径'],[]);
  MenuRunError:='导入领接矩阵错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('net.clear');
  Frame_AufScript1.Memo_cmd.Lines.Add('io.inp.adj "'+Dialog_TC2.Values[0]+'"');
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.loop');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.MenuItem_Network_ImportEdgelistClick(Sender: TObject);
begin
  //
end;

procedure TForm_Main.MenuItem_Network_ImportGeoJSONClick(Sender: TObject);
begin
  Dialog_TC2.Call('导入GeoJSON',['文件路径'],[]);
  MenuRunError:='导入GeoJSON错误。';
  Frame_AufScript1.Memo_cmd.Clear;
  Frame_AufScript1.Memo_cmd.Lines.Add('net.clear');
  Frame_AufScript1.Memo_cmd.Lines.Add('io.inp.json "'+Dialog_TC2.Values[0]+'"');
  Frame_AufScript1.Memo_cmd.Lines.Add('lay.geo');
  Frame_AufScript1.Auf.Script.command(Frame_AufScript1.Memo_cmd.Lines,true);
end;

procedure TForm_Main.PaintBox_NetPaint(Sender: TObject);
var PB:TPaintBox;
    pi:integer;
    W,H,L,R,T,B,WW,HH:{integer}double;
    NodeLabel:TLabelTypeNode;//integer;
    EdgeLabel:TLabelTypeEdge;//integer;
    n1,n2,a1,a2:TPoint;
    //show_arrow,node_label,edge_label:boolean;
    edge_width,edge_display_value,node_size:double;
    edge_display_precision:smallint;
    node_size_value:qword;

begin
  PB:=Sender as TPaintBox;
  if not assigned(netw) then exit;
  if (netw.NodeCount=0) and (netw.ActorCount=0) then exit;

  //show_arrow:=paintOption.Edge.ShowArrow;//CheckBox_ShowEdgeArrow.Checked;
  //node_label:=paintOption.Node.Shown;//CheckBox_ShowNodeLabel.Checked;
  //edge_label:=paintOption.Edge.Shown;//CheckBox_ShowEdgeLabel.Checked;

  edge_width:=paintOption.Edge.WidthOption.scale;//FloatSpinEdit_EdgeWidth.Value;
  node_size:=paintOption.Node.SizeOption.scale;//FloatSpinEdit_NodeSize.Value;

  NodeLabel:=paintOption.Node.LabelOption.LabelType;//Self.RadioGroup_NodeLabel.ItemIndex;
  EdgeLabel:=paintOption.Edge.LabelOption.LabelType;//Self.RadioGroup_EdgeLabel.ItemIndex;
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

  //计算更新顶点的画布坐标
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

  //绘制边线
  IF paintOption.Edge.Shown{CheckBox_ShowEdges.Checked} THEN BEGIN
    for pi:=0 to netw.EdgeCount-1 do
      with netw.Edges[pi] do
        begin
          //计算坐标和标注数值
          case EdgeLabel of
            lteFrequency{3}:  begin  edge_display_value:=frequent;  edge_display_precision:=2;   end;
            lteWeight{2}:     begin  edge_display_value:=weight;    edge_display_precision:=1;   end;
            lteID{1}:         begin  edge_display_value:=id;        edge_display_precision:=0;   end;
            else              begin  edge_display_value:=0;         edge_display_precision:=-1;  end;
          end;
          GetArrowPoint(nodes[0].paint_pos,nodes[1].paint_pos,6,n1,n2,a1,a2);
          //画线
          PB.Canvas.Pen.Color:=clBlack;
          PB.Canvas.Pen.Width:=trunc(edge_width*edge_display_value)+1;
          PB.Canvas.Line(n1,n2);
          //画箭头
          if paintOption.Edge.ShowArrow{show_arrow} then begin
            PB.Canvas.Brush.Style:=bsSolid;
            PB.Canvas.Brush.Color:=clBlack;
            //PB.Canvas.Pen.Color:=clBlack;
            //PB.Canvas.Pen.Color:=clBlack;
            PB.Canvas.Polygon([n2,a1,a2]);
          end;
          //标注
          IF paintOption.Edge.LabelOption.Enabled{edge_label} THEN BEGIN
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

  //绘制OD
  IF paintOption.OD.Shown{CheckBox_ShowODs.Checked} THEN BEGIN
    for pi:=0 to netw.ODCount-1 do
      with netw.ODs[pi] do
        begin
          //计算坐标和标注数值
          GetArrowPoint(actors[0].paint_pos,actors[1].paint_pos,6,n1,n2,a1,a2);
          //画线
          PB.Canvas.Pen.Color:=clBlack;
          PB.Canvas.Pen.Width:=1;
          PB.Canvas.Line(n1,n2);
          //画箭头
          if paintOption.OD.ShowArrow{show_arrow} then begin
            PB.Canvas.Brush.Style:=bsSolid;
            PB.Canvas.Brush.Color:=clBlack;
            //PB.Canvas.Pen.Color:=clBlack;
            //PB.Canvas.Pen.Color:=clBlack;
            PB.Canvas.Polygon([n2,a1,a2]);
          end;
        end;
  END;

  //绘制顶点标注
  IF paintOption.Node.Shown{CheckBox_ShowNodes.Checked} THEN BEGIN
    IF paintOption.Node.LabelOption.Enabled{node_label} THEN BEGIN
      PB.Canvas.Brush.Style:=bsClear;
      PB.Canvas.Font.Color:=clRed;
      PB.Canvas.Font.Size:=10;
      for pi:=0 to netw.NodeCount-1 do
        with netw.Nodes[pi] do
          begin
            case NodeLabel of
              ltnResult{4}:begin
                if is_na(CalcResult) then
                  PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,'N/A')
                else
                  PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,FloatToStrF(CalcResult,ffFixed,1,1));
              end;
              ltnGroup{3}:   PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,IntToStr(Group));
              ltnName{2}:    PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,Utf8toWinCP(name));
              ltnID{1}:      PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,IntToStr(id));
              else ;
            end;
          end;
    END;
  END;

  //绘制顶点符号
  IF paintOption.Node.Shown{CheckBox_ShowNodes.Checked} THEN BEGIN
    PB.Canvas.Brush.Style:=bsSolid;
    PB.Canvas.Brush.Color:=clRed;
    PB.Canvas.Pen.Width:=1;
    PB.Canvas.Pen.Color:=clBlack;
    for pi:=0 to netw.NodeCount-1 do
      with netw.Nodes[pi] do
        begin
          PB.Canvas.Brush.Color:=Color;
          if NodeLabel=ltnResult{4} then begin
            if is_na(CalcResult) then
              node_size_value:=0
            else
              node_size_value:=trunc(CalcResult*node_size/2);
          end else begin
            node_size_value:=5;
          end;
          PB.Canvas.Rectangle(
            paint_pos.x-node_size_value,
            paint_pos.y-node_size_value,
            paint_pos.x+node_size_value,
            paint_pos.y+node_size_value
          );
          //PB.Canvas.Chord(paint_pos.x-5,paint_pos.y-5,paint_pos.x+5,paint_pos.y+5,0,360*16);
        end;
  END;

  //绘制行动者标注
  IF paintOption.Actor.Shown{CheckBox_ShowActors.Checked} THEN BEGIN
    IF paintOption.Actor.Shown{node_label} THEN BEGIN
      PB.Canvas.Brush.Style:=bsClear;
      PB.Canvas.Font.Color:=clBlue;
      PB.Canvas.Font.Size:=8;
      for pi:=0 to netw.ActorCount-1 do
        with netw.Actors[pi] do
          PB.Canvas.TextOut(paint_pos.x+10,paint_pos.y,IntToStr(id));
    END;
  END;

  //绘制行动者符号
  IF paintOption.Actor.Shown{CheckBox_ShowActors.Checked} THEN BEGIN
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

procedure TForm_Main.RadioGroup_EdgeLabelTypeClick(Sender: TObject);
begin
  case (Sender as TRadioGroup).ItemIndex of
    1:paintOption.Edge.LabelOption.LabelType:=lteID;
    2:paintOption.Edge.LabelOption.LabelType:=lteWeight;
    3:paintOption.Edge.LabelOption.LabelType:=lteFrequency;
    else paintOption.Edge.LabelOption.LabelType:=lteNone;
  end;
  Repaint;
end;

procedure TForm_Main.RadioGroup_NodeLabelTypeClick(Sender: TObject);
begin
  case (Sender as TRadioGroup).ItemIndex of
    1:paintOption.Node.LabelOption.LabelType:=ltnID;
    2:paintOption.Node.LabelOption.LabelType:=ltnName;
    3:paintOption.Node.LabelOption.LabelType:=ltnGroup;
    4:paintOption.Node.LabelOption.LabelType:=ltnResult;
    else paintOption.Node.LabelOption.LabelType:=ltnNone;
  end;
  Repaint;
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
  SG.Cells[1,0]:='权重';
  SG.Cells[2,0]:='node_1';
  SG.Cells[3,0]:='node_2';
  SG.Cells[4,0]:='流量';
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

procedure TForm_Main.CheckBox_ShowEdgeArrowClick(Sender: TObject);
begin
  paintOption.Edge.ShowArrow:=(Sender as TCheckBox).Checked;
  Repaint;
end;

procedure TForm_Main.CheckBox_ShowEdgesClick(Sender: TObject);
begin
  paintOption.Edge.Shown:=(Sender as TCheckBox).Checked;
  Repaint;
end;

procedure TForm_Main.CheckBox_ShowNodesClick(Sender: TObject);
begin
  paintOption.Node.Shown:=(Sender as TCheckBox).Checked;
  Repaint;
end;

procedure TForm_Main.CheckBox_ShowODsClick(Sender: TObject);
begin
  paintOption.OD.Shown:=(Sender as TCheckBox).Checked;
  Repaint;
end;

procedure TForm_Main.FloatSpinEdit_EdgeWidthEditingDone(Sender: TObject);
begin
  paintOption.Edge.WidthOption.scale:=(Sender as TFloatSpinEdit).Value;
  Repaint;
end;

procedure TForm_Main.FloatSpinEdit_NodeSizeEditingDone(Sender: TObject);
begin
  paintOption.Node.SizeOption.scale:=(Sender as TFloatSpinEdit).Value;
  Repaint;
end;

procedure TForm_Main.CheckBox_ShowEdgeLabelClick(Sender: TObject);
begin
  paintOption.Edge.LabelOption.Enabled:=(Sender as TCheckBox).Checked;
  Repaint;
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
    ShowMessage('导出成功。');
  except
    ShowMessage('导出失败。');
  end;
end;

procedure TForm_Main.Button_runClick(Sender: TObject);
begin
  EndingMessage:='';
  Frame_AufScript1.Button_runClick(Self);
end;

procedure TForm_Main.CheckBox_ShowActorLabelClick(Sender: TObject);
begin
  paintOption.Actor.LabelOption.Enabled:=(Sender as TCheckBox).Checked;
  Repaint;
end;

procedure TForm_Main.CheckBox_ShowNodeLabelClick(Sender: TObject);
begin
  paintOption.Node.LabelOption.Enabled:=(Sender as TCheckBox).Checked;
  Repaint;
end;

procedure TForm_Main.CheckBox_ShowActorsClick(Sender: TObject);
begin
  paintOption.Actor.Shown:=(Sender as TCheckBox).Checked;
  Repaint;
end;

procedure TForm_Main.UpdatePaintOptionToForm(a_paintOption:TPaintOption);
begin
  with a_paintOption do begin
    CheckBox_ShowNodes.Checked:=Node.Shown;
    CheckBox_ShowNodeLabel.Checked:=Node.LabelOption.Enabled;
    case Node.LabelOption.LabelType of
      ltnID:RadioGroup_NodeLabelType.ItemIndex:=1;
      ltnName:RadioGroup_NodeLabelType.ItemIndex:=2;
      ltnGroup:RadioGroup_NodeLabelType.ItemIndex:=3;
      ltnResult:RadioGroup_NodeLabelType.ItemIndex:=4;
      else RadioGroup_NodeLabelType.ItemIndex:=0;
    end;
    FloatSpinEdit_NodeSize.Value:=Node.SizeOption.scale;

    CheckBox_ShowEdges.Checked:=Edge.Shown;
    CheckBox_ShowEdgeLabel.Checked:=Edge.LabelOption.Enabled;
    CheckBox_ShowEdgeArrow.Checked:=Edge.ShowArrow;
    case Edge.LabelOption.LabelType of
      lteID:RadioGroup_EdgeLabelType.ItemIndex:=1;
      lteWeight:RadioGroup_EdgeLabelType.ItemIndex:=2;
      lteFrequency:RadioGroup_EdgeLabelType.ItemIndex:=3;
      else RadioGroup_EdgeLabelType.ItemIndex:=0;
    end;
    FloatSpinEdit_EdgeWidth.Value:=Edge.WidthOption.scale;

    CheckBox_ShowActors.Checked:=Actor.Shown;
    CheckBox_ShowActorLabel.Checked:=Actor.LabelOption.Enabled;

    CheckBox_ShowODs.Checked:=OD.Shown;
    //CheckBox_ShowODLabel.Checked:=OD.LabelOption.Enabled;

  end;
end;

end.
