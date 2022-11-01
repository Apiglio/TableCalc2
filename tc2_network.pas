unit tc2_network;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Graphics, TypInfo, fpjson, jsonparser, Apiglio_Useful;

const
      //NA:double=$7fffffffffffffff;
      MAX_DOUBLE:double=1.79769313486231570E+308;
      MIN_DOUBLE:double=-1.79769313486231570E+308;
      NA=1.79769313486231570E+308;//MAX_DOUBLE;

type

  pFuncStr=procedure(Sender:TObject;str:string);

  ConnectedError=class(Exception);


  TLabelTypeNode = (ltnNone, ltnID, ltnName, ltnGroup, ltnResult);
  TLabelTypeEdge = (lteNone, lteID, lteWeight, lteFrequency);
  TLabelTypeActor = (ltaNone, ltaID, ltaName);
  TLabelTypeOD = (ltoNone, ltoID, ltoDist);

  TScaleTypeNode = (stnNone, stnResult);
  TScaleTypeEdge = (steNone, steWeight, steFrequency);
  TScaleTypeActor = (staNone);
  TScaleTypeOD = (stoNone, stoDist);

  TColorTypeNode = (ctnNone);
  TColorTypeEdge = (cteNone);
  TColorTypeActor = (ctaNone);
  TColorTypeOD = (ctoNone);


  TPaintOption = class
    Node:record
      Shown:boolean;
      LabelOption:record
        Enabled:boolean;
        LabelType:TLabelTypeNode;
        LabelFont:TFont;
      end;
      SizeOption:record
        Scale:double;
        ScaleType:TScaleTypeNode;
      end;
      ColorOption:record
        Color:TColor;
        ColorType:TColorTypeNode;
      end;
    end;
    Edge:record
      Shown:boolean;
      ShowArrow:boolean;
      LabelOption:record
        Enabled:boolean;
        LabelType:TLabelTypeEdge;
        LabelFont:TFont;
      end;
      WidthOption:record
        Scale:double;
        ScaleType:TScaleTypeEdge;
      end;
      ColorOption:record
        Color:TColor;
        ColorType:TColorTypeEdge;
      end;
    end;
    Actor:record
      Shown:boolean;
      LabelOption:record
        Enabled:boolean;
        LabelType:TLabelTypeActor;
        LabelFont:TFont;
      end;
      SizeOption:record
        Scale:double;
        ScaleType:TScaleTypeActor;
      end;
      ColorOption:record
        Color:TColor;
        ColorType:TColorTypeActor;
      end;
    end;
    OD:record
      Shown:boolean;
      ShowArrow:boolean;
      LabelOption:record
        Enabled:boolean;
        LabelType:TLabelTypeOD;
        LabelFont:TFont;
      end;
      WidthOption:record
        Scale:double;
        ScaleType:TScaleTypeOD;
      end;
      ColorOption:record
        Color:TColor;
        ColorType:TColorTypeOD;
      end;
    end;
    Bound:record
      Top,Left,Right,Bottom:double;
    end;
  public
    constructor Create;
    destructor Destroy; override;
  end;


  TTC2_Edge=class;
  TTC2_Node=class
  public
    name:string;
    id:integer;
    EdgesIn:TList;
    EdgesOut:TList;
    pos:record x,y:double;end;
    latlong:record x,y:double;end;
    paint_pos:TPoint;//这个用来存储Paint过程中的屏幕坐标
    Color:TColor;
    Group:integer;
    CalcResult:double;
  private
    //FAttrbutes:TStringList;
  public
    constructor Create;
    destructor Destroy;
    function CheckInNode(node:TTC2_Node):boolean;
    function CheckOutNode(node:TTC2_Node):boolean;

  private
    // 这里放一些计算时要用到的临时状态变量
    distance:double;
    path:TList;
    pathcount:integer;//如果存在多个最短路径，这个增加，然后直接在path中追加
    enabled:boolean;

  end;
  TTC2_Edge=class
  public
    id:integer;
    weight:double;
    nodes:array[0..1]of TTC2_Node;
    frequent:double;
  public
    constructor Create;
    destructor Destroy;
  private
    // 这里放一些计算时要用到的临时状态变量
    enabled:boolean;

  end;

  TTC2_Actor=class
    id:integer;
    name:string;
    edge:TTC2_Edge;
    //nodes:array[0..1]of TTC2_Node;//没有必要，直接用edge.nodes
    distance:double;
    node_distance:array[0..1]of double;//到nodes的距离
    weight:double;//权重

    pos:record x,y:double;end;
    latlong:record x,y:double;end;
    paint_pos:TPoint;//这个用来存储Paint过程中的屏幕坐标
    Color:TColor;

  end;

  TTC2_ActorOD=class
    id:integer;
    fid:longint;//for arcgis feature
    actors:array[0..1]of TTC2_Actor;
    distance:double;
  end;

  TTC2_NodeSet=class
    FNodeList:TList;
  public
    constructor Create;
    destructor Destroy;
  end;

  TTC2_Path=class
    FEdgeList:TList;
  public
    constructor Create;
    destructor Destroy;
  end;


  TTC2_Network=class
  private
    FNodeList:TList;
    FEdgeList:TList;
    FActorList:TList;
    FActorOD:TList;
    //以下不是构造数据，为派生数据
    FNodeSetList:TList;
    FPathList:TList;

  protected
    function GetNode(index:longint):TTC2_Node;
    function GetEdge(index:longint):TTC2_Edge;
    function GetActor(index:longint):TTC2_Actor;
    function GetOD(index:longint):TTC2_ActorOD;
  public
    property Nodes[index:longint]:TTC2_Node read GetNode;
    property Edges[index:longint]:TTC2_Edge read GetEdge;
    property Actors[index:longint]:TTC2_Actor read GetActor;
    property ODs[index:longint]:TTC2_ActorOD read GetOD;
  public
    function NodeCount:longint;
    function EdgeCount:longint;
    function ActorCount:longint;
    function ODCount:longint;


  public
    constructor Create;
    destructor Destory;
    procedure Clear;

    procedure ClearNodes;
    procedure ClearEdges;
    procedure ClearActors;
    procedure ClearODs;

    procedure ClearNodeSets;
    procedure ClearPaths;

    function AddNode(name:string):TTC2_Node;
    function AddNodeIndex(name:string):integer;
    function AddActor(name:string):TTC2_Actor;
    function AddActorIndex(name:string):integer;
    function AddEdge(Ori,Dest:TTC2_Node):TTC2_Edge;
    function AddEdgeIndex(Ori,Dest:integer;weight:double=1):integer;

    function AddOD(a1,a2:TTC2_Actor):TTC2_ActorOD;

    procedure DeleteNode(node:TTC2_Node);//删除顶点，并将与之相连的所有联系分担计算到各处

  public//private
    procedure UpdateNodeId;
    procedure ZeroizeNodeResult;
    procedure ZeroizeEdgeFrequent;

    function Connected(n1,n2:TTC2_Node;indirect:boolean=true):boolean;
    function ReverseEdge(edge:TTC2_Edge):TTC2_Edge;
    function FindNodeByName(name:string):TTC2_Node;
    function FindNodeIndexByName(nodename:string):integer;
    function FindActorByName(name:string):TTC2_Actor;
    function FindActorIndexByName(actorname:string):integer;

  public
    procedure ReverseWeight;
    procedure IndirectGraphy;
    procedure IndirectWeightCheck(Sender:TObject;func:pFuncStr=nil);

    procedure ComplementGraphy(indirect:boolean=true);//生成补图

    procedure FrequencySum(is_indirect:boolean);


    procedure RemoveMidNode;//删除网络中不影响拓扑结构的顶点，即删除过境点
    procedure SpatialEdgeWeight;//根据点坐标计算距离作为权重



  public
    procedure SaveToAdjacentCSV(filename:string);
    procedure LoadFromAdjacentCSV(filename:string);
    procedure SaveToGraphML(filename:string);

    procedure LoadFromGeoJson(filename:string);
    procedure SaveToGeoJson(filename:string);
    procedure LoadActorsFromGeoJson(filename:string);

    procedure LoadODsFromGeoJson(filename:string);
    procedure SaveODsToGeoJson(filename:string);


  private
    //此部分运行结果有额外信息储存在Node中
    procedure GetDistance(node:TTC2_Node);//计算单点距离
    procedure FindDistance(node,target:TTC2_Node);//计算单点到目标点的距离，阉割版GetDistance
    function GetEccentricity(node:TTC2_Node):double;//计算单点离心率

  public//图论计算
    function CalcDensity:double;//网络密度
    function CalcDiameter:double;//网络直径
    function CalcRadius:double;//网络半径
    function CalcWiener:double;//维纳指数

    function CalcClusteringCoefficient(var arr:pdouble):double;//聚类系数（同时返回每个点的局部聚类系数）
    function CalcConnectedComponent(var arr:pdouble):integer;//连通分量（同时返回每个点的连通分量序号）
    function CalcBipartiteGraphy:boolean;//检验是否是二部图

    procedure CalcDegreeCentrality(var arr:pdouble);//点度中心度
    procedure CalcClosenessCentrality(var arr:pdouble);//接近中心度
    procedure CalcInfluenceRangeClosenessCentrality(var arr:pdouble);//非连通图接近中心度
    procedure CalcBetweennessCentrality(var arr:pdouble);//中介中心度

    procedure DistanceTest(index:integer;var arr:pdouble);//单点距离测试


  public//基于行动者的路径分析

    procedure BuildODAsBlock;//任意两个actor之间建立双向OD联系
    procedure BuildODAsRandom(possibility:double);//创建随机的OD联系，possibility为每对actor之间发生OD的概率

    function ODTest(actor1,actor2:TTC2_Actor{:integer}):double;//行动者路径测试
    procedure ODFrequency(Sender:TObject);//所有行动者两两计算结果，并将结果保存在Edge.frequent

  public
    procedure ActorEdgeUpdate(Sender:TObject;func:pFuncStr=nil);//更新行动者的最近边线

  public
    procedure GetMaxMinXY(var min_x,min_y,max_x,max_y:double);


  end;

  function is_na(value:double):boolean;

implementation
uses tc2_mainform;

function is_na(value:double):boolean;
begin
  if (value=MAX_DOUBLE) or (value=MIN_DOUBLE) then result:=true else result:=false;
end;

procedure Debugln(str:string);
begin
  Form_Main.Frame_AufScript1.Auf.Script.writeln(str);
  Form_Main.Frame_AufScript1.Auf.Script.Func_process.mid(Form_Main.Frame_AufScript1.Auf.Script);
end;
procedure ProcBar(pos,max:integer);
begin
  Form_Main.Frame_AufScript1.ProgressBar.Max:=max;
  Form_Main.Frame_AufScript1.ProgressBar.Position:=pos;
  Form_Main.Frame_AufScript1.Auf.Script.Func_process.mid(Form_Main.Frame_AufScript1.Auf.Script);
end;
function CheckHaltOff:boolean;
begin
  Form_Main.Frame_AufScript1.Auf.Script.Func_process.mid(Form_Main.Frame_AufScript1.Auf.Script);
  result:=Form_Main.Frame_AufScript1.Auf.Script.PSW.haltoff;
end;


constructor TTC2_Node.Create;
begin
  inherited Create;
  EdgesIn:=TList.Create;
  EdgesOut:=TList.Create;
  path:=TList.Create;
  //FAttrbutes:=TStringList.Create;
  enabled:=true;
  Pos.x:=0;
  Pos.y:=0;
  Color:=clRed;
end;
destructor TTC2_Node.Destroy;
begin
  EdgesIn.Free;
  EdgesOut.Free;
  path.Free;
  //FAttrbutes.Free;
  Inherited Destroy;
end;
function TTC2_Node.CheckInNode(node:TTC2_Node):boolean;
var pi:integer;
begin
  result:=true;
  if EdgesIn.Count>0 then for pi:=0 to EdgesIn.Count-1 do
    if TTC2_Edge(EdgesIn[pi]).nodes[0]=node then exit;
  result:=false;
end;
function TTC2_Node.CheckOutNode(node:TTC2_Node):boolean;
var pi:integer;
begin
  result:=true;
  if EdgesOut.Count>0 then for pi:=0 to EdgesOut.Count-1 do
    if TTC2_Edge(EdgesOut[pi]).nodes[1]=node then exit;
  result:=false;
end;

constructor TTC2_Edge.Create;
begin
  inherited Create;
  weight:=1;
  enabled:=true;
end;

destructor TTC2_Edge.Destroy;
begin
  //
  Inherited Destroy;
end;

constructor TTC2_NodeSet.Create;
begin
  inherited Create;
  FNodeList:=TList.Create;
end;

destructor TTC2_NodeSet.Destroy;
begin
  while FNodeList.Count>0 do
    begin
      TTC2_Node(FNodeList[0]).Free;
      FNodeList.Delete(0);
    end;
  Inherited Destroy;
end;

constructor TTC2_Path.Create;
begin
  inherited Create;
  FEdgeList:=TList.Create;
end;

destructor TTC2_Path.Destroy;
begin
  while FEdgeList.Count>0 do
    begin
      TTC2_Edge(FEdgeList[0]).Free;
      FEdgeList.Delete(0);
    end;
  Inherited Destroy;
end;


constructor TTC2_Network.Create;
begin
  FNodeList:=TList.Create;
  FEdgeList:=TList.Create;
  FActorList:=TList.Create;
  FActorOD:=TList.Create;

  FNodeSetList:=TList.Create;
  FPathList:=TList.Create;
end;

destructor TTC2_Network.Destory;
begin
  Self.Clear;
  FNodeList.Free;
  FEdgeList.Free;
  FActorList.Free;
  FActorOD.Free;

  FNodeSetList.Free;
  FPathList.Free;
end;

function TTC2_Network.GetNode(index:longint):TTC2_Node;
begin
  if (index<0) or (index>=FNodeList.Count) then result:=nil
  else result:=TTC2_Node(FNodeList[index]);
end;
function TTC2_Network.GetEdge(index:longint):TTC2_Edge;
begin
  if (index<0) or (index>=FEdgeList.Count) then result:=nil
  else result:=TTC2_Edge(FEdgeList[index]);
end;
function TTC2_Network.GetActor(index:longint):TTC2_Actor;
begin
  if (index<0) or (index>=FActorList.Count) then result:=nil
  else result:=TTC2_Actor(FActorList[index]);
end;
function TTC2_Network.GetOD(index:longint):TTC2_ActorOD;
begin
  if (index<0) or (index>=FActorOD.Count) then result:=nil
  else result:=TTC2_ActorOD(FActorOD[index]);
end;
function TTC2_Network.NodeCount:longint;
begin
  result:=FNodeList.Count;
end;
function TTC2_Network.EdgeCount:longint;
begin
  result:=FEdgeList.Count;
end;
function TTC2_Network.ActorCount:longint;
begin
  result:=FActorList.Count;
end;
function TTC2_Network.ODCount:longint;
begin
  result:=FActorOD.Count;
end;

procedure TTC2_Network.Clear;
begin
  ClearNodes;
  ClearEdges;
  ClearActors;
  ClearODs;

  ClearNodeSets;
  ClearPaths;
end;

procedure TTC2_Network.ClearNodes;
begin
  while FNodeList.Count>0 do
    begin
      TTC2_Node(FNodeList.Items[0]).Free;
      FNodeList.Delete(0);
    end;
end;

procedure TTC2_Network.ClearEdges;
begin
  while FEdgeList.Count>0 do
    begin
      TTC2_Edge(FEdgeList.Items[0]).Free;
      FEdgeList.Delete(0);
    end;
end;

procedure TTC2_Network.ClearActors;
begin
  while FActorList.Count>0 do
    begin
      TTC2_Actor(FActorList.Items[0]).Free;
      FActorList.Delete(0);
    end;
end;

procedure TTC2_Network.ClearODs;
begin
  while FActorOD.Count>0 do
    begin
      TTC2_ActorOD(FActorOD.Items[0]).Free;
      FActorOD.Delete(0);
    end;
end;

procedure TTC2_Network.ClearNodeSets;
begin
  while FNodeSetList.Count>0 do
    begin
      TTC2_NodeSet(FNodeSetList.Items[0]).Free;
      FNodeSetList.Delete(0);
    end;
end;

procedure TTC2_Network.ClearPaths;
begin
  while FPathList.Count>0 do
    begin
      TTC2_Path(FPathList.Items[0]).Free;
      FPathList.Delete(0);
    end;
end;

function TTC2_Network.AddNode(name:string):TTC2_Node;
var tmpNode:TTC2_Node;
begin
  tmpNode:=TTC2_Node.Create;
  tmpNode.name:=name;
  tmpNode.id:=FNodeList.Count;
  FNodeList.Add(tmpNode);
  result:=tmpNode;
end;
function TTC2_Network.AddNodeIndex(name:string):integer;
begin
  result:=AddNode(name).id;
end;
function TTC2_Network.AddActor(name:string):TTC2_Actor;
var tmpActor:TTC2_Actor;
begin
  tmpActor:=TTC2_Actor.Create;
  tmpActor.name:=name;
  tmpActor.id:=FActorList.Count;
  FActorList.Add(tmpActor);
  result:=tmpActor;
end;
function TTC2_Network.AddActorIndex(name:string):integer;
begin
  result:=AddActor(name).id;
end;


function TTC2_Network.AddEdge(Ori,Dest:TTC2_Node):TTC2_Edge;
var tmpEdge:TTC2_Edge;
begin
  tmpEdge:=TTC2_Edge.Create;
  tmpEdge.nodes[0]:=Ori;
  tmpEdge.nodes[1]:=Dest;
  tmpEdge.id:=FEdgeList.Count;
  FEdgeList.Add(tmpEdge);
  Ori.EdgesOut.Add(tmpEdge);
  Dest.EdgesIn.Add(tmpEdge);
  result:=tmpEdge;
end;
function TTC2_Network.AddEdgeIndex(Ori,Dest:integer;weight:double=1):integer;
var tmp:TTC2_Edge;
begin
  tmp:=AddEdge(TTC2_Node(FNodeList.Items[Ori]),TTC2_Node(FNodeList.Items[Dest]));
  tmp.weight:=weight;
  result:=tmp.id;
end;

function TTC2_Network.AddOD(a1,a2:TTC2_Actor):TTC2_ActorOD;
var tmp:TTC2_ActorOD;
begin
  tmp:=TTC2_ActorOD.Create;
  tmp.actors[0]:=a1;
  tmp.actors[1]:=a2;
  tmp.fid:=0;
  tmp.id:=FActorOD.Count;
  FActorOD.Add(tmp);
  result:=tmp;
end;

procedure TTC2_Network.DeleteNode(node:TTC2_Node);
var tmpA,tmpB:Pointer;
    edgA,edgB,edgC:TTC2_Edge;
    nodA,nodB:TTC2_Node;
    tmpWeight:Double;
begin
  for tmpA in node.EdgesIn do
    begin
      edgA:=TTC2_Edge(tmpA);
      for tmpB in node.EdgesOut do
        begin
          edgB:=TTC2_Edge(tmpB);
          tmpWeight:=edgA.weight+edgB.weight;
          nodA:=edgA.nodes[0];
          nodB:=edgB.nodes[1];
          if nodA=nodB then Continue;
          nodB.EdgesIn.Remove(edgB);
          edgC:=AddEdge(nodA,nodB);
          edgC.weight:=tmpWeight;
          FEdgeList.Remove(edgA);
          FEdgeList.Remove(edgB);
        end;
      nodA.EdgesOut.Remove(edgA);
    end;
  FNodeList.Remove(node);
end;

procedure TTC2_Network.UpdateNodeId;
var pi:integer;
begin
  for pi:=0 to FNodeList.Count-1 do TTC2_Node(FNodeList[pi]).id:=pi;
end;
procedure TTC2_Network.ZeroizeNodeResult;
var pi:integer;
begin
  for pi:=0 to FNodeList.Count-1 do TTC2_Node(FNodeList[pi]).CalcResult:=0;
end;
procedure TTC2_Network.ZeroizeEdgeFrequent;
var pi:integer;
begin
  for pi:=0 to FEdgeList.Count-1 do TTC2_Edge(FEdgeList[pi]).frequent:=0;
end;




function TTC2_Network.Connected(n1,n2:TTC2_Node;indirect:boolean=true):boolean;
var tmp:Pointer;
begin
  result:=true;
  for tmp in n1.EdgesIn do
    if TTC2_Edge(tmp).nodes[0] = n2 then exit;
  if indirect then
    for tmp in n1.EdgesOut do
      if TTC2_Edge(tmp).nodes[1] = n2 then exit;
  result:=false;
end;

function TTC2_Network.ReverseEdge(edge:TTC2_Edge):TTC2_Edge;
var n1,n2:TTC2_Node;
    tmpE:Pointer;
    e2:TTC2_Edge;
begin
  n1:=edge.nodes[0];
  n2:=edge.nodes[1];
  for tmpE in n2.EdgesOut do
    begin
      e2:=TTC2_Edge(tmpE);
      if e2.nodes[1]=n1 then
        begin
          result:=e2;
          exit;
        end;
    end;
  result:=nil;
end;

function TTC2_Network.FindNodeByName(name:string):TTC2_Node;
var index:integer;
begin
  index:=FindNodeIndexByName(name);
  if index>=0 then result:=TTC2_Node(FNodeList[index])
  else result:=nil;
end;
function TTC2_Network.FindNodeIndexByName(nodename:string):integer;
begin
  result:=0;
  while result<FNodeList.Count do
    begin
      if TTC2_Node(FNodeList[result]).name=nodename then exit;
      inc(result);
    end;
  result:=-1;
end;
function TTC2_Network.FindActorByName(name:string):TTC2_Actor;
var index:integer;
begin
  index:=FindActorIndexByName(name);
  if index>=0 then result:=TTC2_Actor(FActorList[index])
  else result:=nil;
end;
function TTC2_Network.FindActorIndexByName(actorname:string):integer;
begin
  result:=0;
  while result<FActorList.Count do
    begin
      if TTC2_Actor(FActorList[result]).name=actorname then exit;
      inc(result);
    end;
  result:=-1;
end;


procedure TTC2_Network.ReverseWeight;
var pi:integer;
    we:double;
begin
  for pi:=0 to FEdgeList.Count-1 do
    begin
      we:=Edges[pi].weight;

      if we=NA then Edges[pi].weight:=0
      else if we=0 then Edges[pi].weight:=NA
      else Edges[pi].weight:=1/we;

    end;
end;
procedure TTC2_Network.IndirectGraphy;
var pi:integer;
    found:boolean;
    tmpP:Pointer;
    w:double;
begin
  for pi:=0 to FEdgeList.Count-1 do
    begin
      found:=false;
      w:=Edges[pi].weight;
      for tmpP in Edges[pi].nodes[1].EdgesOut do
        begin
          if TTC2_Edge(tmpP).nodes[1]=Edges[pi].nodes[0] then
            begin
              found:=true;
              break;
            end;
        end;
      if not found then
        AddEdge(Edges[pi].nodes[1],Edges[pi].nodes[0]).weight:=w;
    end;
end;
procedure TTC2_Network.IndirectWeightCheck(Sender:TObject;func:pFuncStr=nil);
var pi:integer;
    E1,E2:TTC2_Edge;
    w1,w2:double;
begin
  for pi:=0 to FEdgeList.Count-1 do Edges[pi].enabled:=true;
  for pi:=0 to FEdgeList.Count-1 do
    begin
      E1:=Edges[pi];
      if not E1.enabled then continue;
      E2:=ReverseEdge(E1);
      if E2<>nil then
        begin
          w1:=E1.weight;
          w2:=E2.weight;
          E2.weight:=(w1+w2)/2;
          E1.weight:=E2.weight;
          E2.enabled:=false;
          E2.enabled:=false;
          if func<>nil then func(Sender,FloatToStrF(w1,ffFixed,1,1)+'+'+FloatToStrF(w2,ffFixed,1,1)+'='+FloatToStrF(E1.weight,ffFixed,1,1));
        end;
    end;
end;

procedure TTC2_Network.ComplementGraphy(indirect:boolean=true);
var pi,pj,pk:longint;
begin
  //补图算法有问题
  for pi:=0 to EdgeCount-1 do
    Edges[pi].enabled:=false;
  for pi:=0 to NodeCount-1 do
    begin
      if indirect then pk:=pi+1 else pk:=0;
      for pj:=pk to NodeCount-1 do
        begin
          if pi=pj then continue;
          if not Connected(Nodes[pi],Nodes[pj],indirect) then
            AddEdgeIndex(pi,pj);
        end;
    end;
  pi:=0;
  while pi<EdgeCount do
    begin
      if not Edges[pi].enabled then
        begin
          Edges[pi].Free;
          FEdgeList.Delete(pi);
        end
      else inc(pi);
    end;
end;

procedure TTC2_Network.FrequencySum(is_indirect:boolean);
var P1,P2,PE:Pointer;
    N1,N2:TTC2_Node;
    E:TTC2_Edge;
    sum1,sum2:double;
begin
  UpdateNodeId;
  for P1 in FNodeList do
    begin
      N1:=TTC2_Node(P1);
      for P2 in FNodeList do
        begin
          N2:=TTC2_Node(P2);
          if N1.id>=N2.id then continue;
          sum1:=0;
          sum2:=0;
          for PE in N1.EdgesIn do
            begin
              E:=TTC2_Edge(PE);
              if E.nodes[0]=N2 then sum1+=E.frequent;
            end;
          for PE in N1.EdgesOut do
            begin
              E:=TTC2_Edge(PE);
              if E.nodes[1]=N1 then sum2+=E.frequent;
            end;
          if is_indirect then
            begin
              sum1:=sum1+sum2;
              sum2:=sum1;
            end;
          for PE in N1.EdgesIn do TTC2_Edge(PE).frequent:=sum1;
          for PE in N1.EdgesOut do TTC2_Edge(PE).frequent:=sum2;
        end;

    end;
end;

procedure TTC2_Network.RemoveMidNode;
var pi:integer;
    tmpNode:TTC2_Node;
    _ei1,_eo1,_ei2,_eo2:TTC2_Edge;
    ec1,ec2:integer;
    function NodesCheck(c1,c2:integer;ei1,ei2,eo1,eo2:TTC2_Edge):boolean;
    begin
      result:=false;
      if c1<>c2 then exit;
      if (c1<>1) and (c1<>2) then exit;
      if (ei2=nil) or (eo2=nil) then
        begin
          result:=(ei1.nodes[0]<>eo1.nodes[1]) and not Connected(ei1.nodes[0],eo1.nodes[1]);
        end
      else
        begin
          result:=(((ei1.nodes[0]<>eo2.nodes[1]) and not Connected(ei1.nodes[0],eo2.nodes[1]))
                and((ei2.nodes[0]<>eo1.nodes[1]) and not Connected(ei2.nodes[0],eo1.nodes[1])))
                OR (((ei1.nodes[0]<>eo1.nodes[1]) and not Connected(ei1.nodes[0],eo1.nodes[1]))
                and((ei2.nodes[0]<>eo2.nodes[1]) and not Connected(ei2.nodes[0],eo2.nodes[1])));
        end;
    end;

begin
  pi:=0;
  while pi<FNodeList.Count do
    begin
      tmpNode:=Nodes[pi];
      if tmpNode.EdgesIn.Count*tmpNode.EdgesOut.Count=0 then begin inc(pi);continue;end;
      _ei1:=TTC2_Edge(tmpNode.EdgesIn[0]);
      _eo1:=TTC2_Edge(tmpNode.EdgesOut[0]);
      ec1:=tmpNode.EdgesIn.Count;
      ec2:=tmpNode.EdgesOut.Count;
      if ec1>1 then _ei2:=TTC2_Edge(tmpNode.EdgesIn[1]) else _ei2:=nil;
      if ec2>1 then _eo2:=TTC2_Edge(tmpNode.EdgesOut[1]) else _eo2:=nil;
      if NodesCheck(ec1,ec2,_ei1,_ei2,_eo1,_eo2) then DeleteNode(tmpNode)
      else inc(pi);
    end;
end;

procedure TTC2_Network.SpatialEdgeWeight;
var pi:integer;
begin
  for pi:=0 to FEdgeList.Count-1 do
    with Edges[pi] do
      begin
        weight:=sqrt(sqr(nodes[0].pos.x-nodes[1].pos.x)+sqr(nodes[0].pos.y-nodes[1].pos.y));
      end;
end;

procedure TTC2_Network.SaveToAdjacentCSV(filename:string);
var tmpMem:TMemoryStream;
    Level,pi,target:integer;
    tmpEdge:Pointer;
    sat:text;
    qv:qword;
    value:double absolute qv;
begin
  UpdateNodeId;
  Level:=FNodeList.Count;
  tmpMem:=TMemoryStream.Create;
  try
    tmpMem.SetSize(Level*Level*8);
    tmpMem.Position:=0;
    value:=0;
    while tmpMem.Position<tmpMem.Size do tmpMem.WriteQWord(qv);
    for pi:=0 to Level-1 do
      begin
        for tmpEdge in Nodes[pi].EdgesOut do
          begin
            target:=TTC2_Edge(tmpEdge).nodes[1].id;
            tmpMem.Seek((pi*Level+target)*8,soFromBeginning);
            qv:=tmpMem.ReadQWord;
            value:=value+TTC2_Edge(tmpEdge).weight;
            tmpMem.Seek(-8,soFromCurrent);
            tmpMem.WriteQWord(qv);
          end;
      end;
    AssignFile(sat,filename);
    Rewrite(sat);
    for pi:=0 to Level-1 do
      begin
        for target:=0 to Level-1 do
          begin
            tmpMem.Seek((pi*Level+target)*8,soFromBeginning);
            qv:=tmpMem.ReadQWord;
            if target<>0 then write(sat,',');
            write(sat,value:3:3);
          end;
        writeln(sat);
      end;
    CloseFile(sat);
  finally
    tmpMem.Free;
  end;
end;
procedure TTC2_Network.LoadFromAdjacentCSV(filename:string);
var sat:text;
    stmp,clip:string;
    pi,pj,poss:integer;
    procedure AddEdgeWeight(weight:string);
    var w:double;
    begin
      while Self.FNodeList.Count<=pj do Self.AddNode('N'+IntToStr(pi));
      try w:=StrToFloat(weight);
      except w:=0; end;
      if w<>0 then Self.AddEdgeIndex(pi,pj,w);
    end;

begin
  try
    assignfile(sat,filename);
    reset(sat);
    pi:=0;
    while not eof(sat) do
      begin
        while Self.FNodeList.Count<=pi do Self.AddNode('N'+IntToStr(pi));
        readln(sat,stmp);
        pj:=0;
        stmp:=StringReplace(stmp,',',#9,[rfReplaceAll]);
        poss:=pos(#9,stmp);
        while poss>0 do
          begin
            clip:=stmp;
            System.delete(clip,poss,length(clip));
            System.delete(stmp,1,poss);
            AddEdgeWeight(clip);
            poss:=pos(#9,stmp);
            inc(pj);
          end;
        AddEdgeWeight(stmp);
        inc(pi);
      end;
    close(sat);
  finally
  end;
end;

procedure TTC2_Network.SaveToGraphML(filename:string);
begin
  UpdateNodeId;
  //佛了，ap_xml都没写完
end;

procedure TTC2_Network.LoadFromGeoJson(filename:string);
var str:TMemoryStream;
    jData,features,paths,path:TJSONData;
    pi,pj,pk:integer;
    x1,x2,y1,y2:double;
    n1,n2:string;
    node1,node2:TTC2_Node;
    function NodeHash(x,y:double):string;
    var s:pchar;
    begin
      result:=FloatToStrF(x,ffFixed,1,1)+'_'+FloatToStrF(y,ffFixed,1,1);
    end;
begin
  str:=TMemoryStream.Create;
  try
    str.LoadFromFile(filename);
    jData:=GetJSON(str);
    features:=jData.FindPath('features');
    for pi:=0 to features.Count-1 do
      begin
        paths:=features.Items[pi].FindPath('geometry.paths');
        for pj:=0 to paths.Count-1 do
          begin
            path:=paths.Items[pj];
            for pk:=0 to path.Count-2 do
              begin
                x1:=path.Items[pk].Items[0].AsFloat;
                y1:=-path.Items[pk].Items[1].AsFloat;
                x2:=path.Items[pk+1].Items[0].AsFloat;
                y2:=-path.Items[pk+1].Items[1].AsFloat;
                n1:=NodeHash(x1,y1);
                n2:=NodeHash(x2,y2);
                node1:=FindNodeByName(n1);
                node2:=FindNodeByName(n2);
                if node1=nil then begin
                  node1:=Self.AddNode(n1);
                  with node1 do begin
                    pos.x:=x1;
                    pos.y:=y1;
                    latlong.x:=x1;
                    latlong.y:=y1;
                  end;
                end;
                if node2=nil then begin
                  node2:=Self.AddNode(n2);
                  with node2 do begin
                    pos.x:=x2;
                    pos.y:=y2;
                    latlong.x:=x2;
                    latlong.y:=y2;
                  end;
                end;
                Self.AddEdge(node1,node2);
              end;
          end;
      end;
  finally
    str.Free;
    jData.Free;
  end;
end;

procedure TTC2_Network.SaveToGeoJson(filename:string);
var str:TStringList;
    pi,pj:longint;
    field_options:array[0..5]of record n,t,a:string;end;
begin
  //真tm离谱
  field_options[0].n:='FID';
  field_options[0].t:='esriFieldTypeOID';
  field_options[0].a:='FID';
  field_options[1].n:='OID';
  field_options[1].t:='esriFieldTypeInteger';
  field_options[1].a:='OID_';
  field_options[2].n:='weight';
  field_options[2].t:='esriFieldTypeDouble';
  field_options[2].a:='weight';
  field_options[3].n:='node_1';
  field_options[3].t:='esriFieldTypeInteger';
  field_options[3].a:='node_1';
  field_options[4].n:='node_2';
  field_options[4].t:='esriFieldTypeInteger';
  field_options[4].a:='node_2';
  field_options[5].n:='freq';
  field_options[5].t:='esriFieldTypeDouble';
  field_options[5].a:='frequency';

  str:=TStringList.Create;
  try
    str.Add('{');
    str.Add('  "displayFieldName" : "",');
    str.Add('  "fieldAliases" : {');
    for pi:=0 to 5 do
      begin
        if pi=5 then
          str.Add('    "'+field_options[pi].n+'" : "'+field_options[pi].a+'"')
        else
          str.Add('    "'+field_options[pi].n+'" : "'+field_options[pi].a+'",');
      end;
    str.Add('  },');
    str.Add('  "geometryType" : "esriGeometryPolyline",');
    str.Add('  "spatialReference" : {"wkid" : null},');
    str.Add('  "fields" : [');
    for pi:=0 to 5 do
      begin
        str.Add('    {');
        str.Add('      "name":"'+field_options[pi].n+'",');
        str.Add('      "type":"'+field_options[pi].t+'",');
        str.Add('      "alias":"'+field_options[pi].a+'"');
        if pi=5 then str.Add('    }') else str.Add('    },');
      end;
    str.Add('  ],');
    str.Add('  "features" : [');
    for pi:=0 to EdgeCount-1 do
      begin
        str.Add('    {');
        str.Add('      "attributes" : {');
        str.Add('        "'+field_options[0].n+'" : '+IntToStr(pi)+',');
        str.Add('        "'+field_options[1].n+'" : 0,');
        str.Add('        "'+field_options[2].n+'" : '+FloatToStrF(Edges[pi].weight,ffFixed,9,9)+',');
        str.Add('        "'+field_options[3].n+'" : '+IntToStr(Edges[pi].nodes[0].id)+',');
        str.Add('        "'+field_options[4].n+'" : '+IntToStr(Edges[pi].nodes[1].id)+',');
        str.Add('        "'+field_options[5].n+'" : '+FloatToStrF(Edges[pi].frequent,ffFixed,9,9));
        str.Add('      },');
        str.Add('      "geometry" : {');
        with Edges[pi] do
          str.Add('        "paths" : [[['
            +FloatToStrF(nodes[0].latlong.x,ffFixed,9,9)+','
            +FloatToStrF(-nodes[0].latlong.y,ffFixed,9,9)+'],['
            +FloatToStrF(nodes[1].latlong.x,ffFixed,9,9)+','
            +FloatToStrF(-nodes[1].latlong.y,ffFixed,9,9)+']]]');
        str.Add('      }');
        if pi=EdgeCount-1 then str.Add('    }')
        else str.Add('    },');
      end;
    str.Add('  ]');
    str.Add('}');
    str.SaveToFile(filename);
  finally
    str.Free;
  end;
end;

procedure TTC2_Network.LoadActorsFromGeoJson(filename:string);
var str:TMemoryStream;
    jData,features,point:TJSONData;
    pi:integer;
    x,y:double;
    n:string;
    actor:TTC2_Actor;
    function ActorHash(x,y:double):string;
    var s:pchar;
    begin
      result:=FloatToStrF(x,ffFixed,1,1)+'_'+FloatToStrF(y,ffFixed,1,1);
    end;
begin
  ClearActors;
  ClearODs;
  str:=TMemoryStream.Create;
  try
    str.LoadFromFile(filename);
    jData:=GetJSON(str);
    features:=jData.FindPath('features');
    for pi:=0 to features.Count-1 do
      begin
        point:=features.Items[pi].FindPath('geometry');
        x:=point.FindPath('x').AsFloat;
        y:=-point.FindPath('y').AsFloat;
        n:=ActorHash(x,y);
        actor:=FindActorByName(n);
        if actor=nil then begin
          actor:=Self.AddActor(n);
          with actor do begin
            pos.x:=x;
            pos.y:=y;
            latlong.x:=x;
            latlong.y:=y;
          end;
        end;
      end;
  finally
    str.Free;
    jData.Free;
  end;
end;

procedure TTC2_Network.LoadODsFromGeoJson(filename:string);
var str:TMemoryStream;
    jData,features,geo,attr,paths:TJSONData;
    pi,_fid:integer;
    x1,y1,x2,y2:double;
    n1,n2:string;
    actor1,actor2:TTC2_Actor;
    function ActorHash(x,y:double):string;
    var s:pchar;
    begin
      result:=FloatToStrF(x,ffFixed,1,1)+'_'+FloatToStrF(y,ffFixed,1,1);
    end;
begin
  ClearActors;
  ClearODs;
  str:=TMemoryStream.Create;
  try
    str.LoadFromFile(filename);
    jData:=GetJSON(str);
    features:=jData.FindPath('features');
    for pi:=0 to features.Count-1 do
      begin
        geo:=features.Items[pi].FindPath('geometry');
        attr:=features.Items[pi].FindPath('attributes');
        _fid:=attr.FindPath('FID').AsInteger;
        paths:=geo.FindPath('paths');
        if paths=nil then continue;
        if paths.Count<=0 then continue;
        x1:=paths.Items[0].Items[0].Items[0].AsFloat;
        y1:=-paths.Items[0].Items[0].Items[1].AsFloat;
        x2:=paths.Items[0].Items[1].Items[0].AsFloat;
        y2:=-paths.Items[0].Items[1].Items[1].AsFloat;
        n1:=ActorHash(x1,y1);
        n2:=ActorHash(x2,y2);
        actor1:=FindActorByName(n1);
        actor2:=FindActorByName(n2);
        if actor1=nil then begin
          actor1:=Self.AddActor(n1);
          with actor1 do begin
            pos.x:=x1;pos.y:=y1;latlong.x:=x1;latlong.y:=y1;
          end;
        end;
        if actor2=nil then begin
          actor2:=Self.AddActor(n2);
          with actor2 do begin
            pos.x:=x2;pos.y:=y2;latlong.x:=x2;latlong.y:=y2;
          end;
        end;
        Self.AddOD(actor1,actor2).fid:=_fid;
      end;
  finally
    str.Free;
    jData.Free;
  end;
end;

procedure TTC2_Network.SaveODsToGeoJson(filename:string);
begin

end;

procedure one_step(node:TTC2_Node);
var tmpPTR,tmpE2:Pointer;
    tmpEdge:TTC2_Edge;
    dist:double;
begin
  for tmpPTR in node.EdgesOut do
    begin
      tmpEdge:=TTC2_Edge(tmpPTR);
      if not tmpEdge.enabled then continue;//做点割边割测试时会涉及禁用边线
      if not tmpEdge.nodes[1].enabled then continue;//做点割边割测试时会涉及禁用节点
      if tmpEdge.nodes[1].distance<node.distance+tmpEdge.weight then continue;

      dist:=tmpEdge.nodes[0].distance+tmpEdge.weight;
      if tmpEdge.nodes[1].distance>dist then
        begin
          tmpEdge.nodes[1].distance:=dist;
          tmpEdge.nodes[1].path.Clear;
          tmpEdge.nodes[1].path.AddList(tmpEdge.nodes[0].path);
          tmpEdge.nodes[1].path.Add(tmpEdge);
          tmpEdge.nodes[1].pathcount:=1;
        end
      else if tmpEdge.nodes[1].distance=dist then
        begin
          tmpEdge.nodes[1].path.AddList(tmpEdge.nodes[0].path);
          tmpEdge.nodes[1].path.Add(tmpEdge);
          tmpEdge.nodes[1].pathcount+=1;
        end;
      one_step(tmpEdge.nodes[1]);
    end;
end;

procedure TTC2_Network.GetDistance(node:TTC2_Node);
var tmpP,tmpE:Pointer;
begin
  for tmpP in FNodeList do
    with TTC2_Node(tmpP) do
      begin
        distance:=MAX_DOUBLE;
        path.Clear;
        pathcount:=0;
        //enabled:=true;
      end;
  //for tmpP in FEdgeList do TTC2_Edge(tmpP).enabled:=true;
  node.distance:=0;
  one_step(node);
  //流量统计
  //ZeroizeEdgeFrequent;//这里没必要单独清零
  for tmpP in FNodeList do
    with TTC2_Node(tmpP) do
      begin
        for tmpE in path do TTC2_Edge(tmpE).frequent:=TTC2_Edge(tmpE).frequent+1/pathcount;
      end;
end;

procedure TTC2_Network.FindDistance(node,target:TTC2_Node);
var tmpP,tmpE:Pointer;
    distance_limitation:double;
    procedure one_step_find_version(node,target:TTC2_Node);
    var tmpPTR,tmpE2:Pointer;
        tmpEdge:TTC2_Edge;
        dist:double;
    begin
      for tmpPTR in node.EdgesOut do
        begin
          tmpEdge:=TTC2_Edge(tmpPTR);
          if not tmpEdge.enabled then continue;//做点割边割测试时会涉及禁用边线
          if not tmpEdge.nodes[1].enabled then continue;//做点割边割测试时会涉及禁用节点
          if tmpEdge.nodes[1].distance<node.distance+tmpEdge.weight then continue;

          dist:=tmpEdge.nodes[0].distance+tmpEdge.weight;
          if dist>distance_limitation then continue;
          if tmpEdge.nodes[1].distance>dist then
            begin
              tmpEdge.nodes[1].distance:=dist;
              tmpEdge.nodes[1].path.Clear;
              tmpEdge.nodes[1].path.AddList(tmpEdge.nodes[0].path);
              tmpEdge.nodes[1].path.Add(tmpEdge);
              tmpEdge.nodes[1].pathcount:=1;
            end
          else if tmpEdge.nodes[1].distance=dist then
            begin
              tmpEdge.nodes[1].path.AddList(tmpEdge.nodes[0].path);
              tmpEdge.nodes[1].path.Add(tmpEdge);
              tmpEdge.nodes[1].pathcount+=1;
            end;
          if tmpEdge.nodes[1]=target then distance_limitation:=target.distance;
          if tmpEdge.nodes[1].distance<distance_limitation then one_step_find_version(tmpEdge.nodes[1],target);
        end;
    end;

begin
  distance_limitation:=MAX_DOUBLE;
  for tmpP in FNodeList do
    with TTC2_Node(tmpP) do
      begin
        distance:=MAX_DOUBLE;
        path.Clear;
        pathcount:=0;
        //enabled:=true;
      end;
  //for tmpP in FEdgeList do TTC2_Edge(tmpP).enabled:=true;
  node.distance:=0;
  one_step_find_version(node,target);
  //流量统计
  //ZeroizeEdgeFrequent;//这里没必要单独清零
  for tmpP in FNodeList do
    with TTC2_Node(tmpP) do
      begin
        for tmpE in path do TTC2_Edge(tmpE).frequent:=TTC2_Edge(tmpE).frequent+1/pathcount;
      end;
end;

function TTC2_Network.GetEccentricity(node:TTC2_Node):double;
var pi:integer;
begin
  result:=0;
  GetDistance(node);
  for pi:=0 to FNodeList.Count-1 do
    if Nodes[pi].distance>result then
      result:=Nodes[pi].distance;
end;

function TTC2_Network.CalcDensity:double;
var V,E:integer;
begin
  result:=0;
  V:=FNodeList.Count;
  E:=FEdgeList.Count;
  if V=0 then exit;
  result:=E/V/(V-1);
end;
function TTC2_Network.CalcDiameter:double;
var pi:integer;
    ecc:double;
begin
  result:=0;
  for pi:=0 to FNodeList.Count-1 do
    begin
      ecc:=GetEccentricity(Nodes[pi]);
      if ecc>result then result:=ecc;
    end;
end;
function TTC2_Network.CalcRadius:double;
var pi:integer;
    ecc:double;
begin
  result:=NA;
  for pi:=0 to FNodeList.Count-1 do
    begin
      ecc:=GetEccentricity(Nodes[pi]);
      if ecc<result then result:=ecc;
    end;
end;
function TTC2_Network.CalcWiener:double;
var pi,pj:integer;
    dist:double;
begin
  result:=0;
  for pi:=0 to FNodeList.Count-1 do
    begin
      GetDistance(Nodes[pi]);
      for pj:=0 to FNodeList.Count-1 do
        begin
          dist:=Nodes[pj].distance;
          if dist=NA then raise ConnectedError.Create('Wiener指数只适用于连通图');
          result+=dist;
        end;
    end;
end;
function TTC2_Network.CalcClusteringCoefficient(var arr:pdouble):double;
var pi,pj,pk,V,E:integer;
    N1,N2,N3:TTC2_Node;
    cls,opn,lc,lo:qword;
begin
  V:=FNodeList.Count;
  cls:=0;opn:=0;
  for pi:=0 to V-1 do
    begin
      lc:=0;lo:=0;
      N1:=Nodes[pi];
      E:=N1.EdgesOut.Count;
      for pj:=0 to E-1 do
        for pk:=0 to E-1 do
          begin
            if pj=pk then continue;
            N2:=TTC2_Edge(N1.EdgesOut[pj]).nodes[1];
            N3:=TTC2_Edge(N1.EdgesOut[pk]).nodes[1];
            if N2.CheckOutNode(N3) then begin
              inc(cls);inc(lc);
            end else begin
              inc(opn);inc(lo);
            end;
          end;
      if lc<>0 then Arr[pi]:=lc/(lo+lc) else Arr[pi]:=0;
    end;
  if cls=0 then result:=0 else result:=cls/(opn+cls);
end;
function TTC2_Network.CalcConnectedComponent(var arr:pdouble):integer;
var pi,pj,V,GI:integer;
    N1,N2:TTC2_Node;
begin
  V:=FNodeList.Count;
  GI:=0;
  for pi:=0 to V-1 do Nodes[pi].Group:=0;
  for pi:=0 to V-1 do
    begin
      N1:=Nodes[pi];
      if N1.Group<>0 then continue;
      inc(GI);
      GetDistance(N1);
      for pj:=pi to V-1 do
        begin
          N2:=Nodes[pj];
          if N2.distance<>NA then N2.Group:=GI;
        end;
    end;
  for pi:=0 to V-1 do Arr[pi]:=Nodes[pi].Group;
  result:=GI;
end;

function TTC2_Network.CalcBipartiteGraphy:boolean;
var pi,V:integer;
begin
  //二部图识别有点麻烦
end;

procedure TTC2_Network.CalcDegreeCentrality(var arr:pdouble);
var pi,V:integer;
    tmpEdge:Pointer;
begin
  V:=FNodeList.Count;
  for pi:=0 to FNodeList.Count-1 do
    begin
      Arr[pi]:=0;
      for tmpEdge in Nodes[pi].EdgesOut do
        Arr[pi]+=TTC2_Edge(tmpEdge).weight;
    end;
  for pi:=0 to FNodeList.Count-1 do
    begin
      Nodes[pi].CalcResult:=Arr[pi];
    end;
end;
procedure TTC2_Network.CalcClosenessCentrality(var arr:pdouble);
var pi,V:integer;
    tmpNode:Pointer;
    we:double;
begin
  V:=FNodeList.Count;
  for pi:=0 to FNodeList.Count-1 do
    begin
      Arr[pi]:=0;
      GetDistance(Nodes[pi]);
      for tmpNode in FNodeList do
        begin
          we:=TTC2_Node(tmpNode).distance;
          if we=NA then raise ConnectedError.Create('接近中心度只适用于连通图');
          Arr[pi]+=we;
        end;
      Arr[pi]:=1/Arr[pi];
    end;
  for pi:=0 to FNodeList.Count-1 do
    begin
      Nodes[pi].CalcResult:=Arr[pi];
    end;
end;
procedure TTC2_Network.CalcInfluenceRangeClosenessCentrality(var arr:pdouble);
var pi,V,J:integer;
    tmpNode:Pointer;
    we:double;
begin
  V:=FNodeList.Count;
  for pi:=0 to FNodeList.Count-1 do
    begin
      Arr[pi]:=0;
      J:=0;
      GetDistance(Nodes[pi]);
      for tmpNode in FNodeList do
        begin
          we:=TTC2_Node(tmpNode).distance;
          if we=NA then else
            begin
              inc(J);
              Arr[pi]+=we;
            end;
        end;
      if Arr[pi]=0 then Arr[pi]:=NA else
      Arr[pi]:=J*J/(V-1)/Arr[pi];
    end;
  for pi:=0 to FNodeList.Count-1 do
    begin
      Nodes[pi].CalcResult:=Arr[pi];
    end;
end;
procedure TTC2_Network.CalcBetweennessCentrality(var arr:pdouble);
var pi,pj,pk,V,tmp:integer;
    tmpEdge:Pointer;
begin
  UpdateNodeId;
  V:=FNodeList.Count;
  for pi:=0 to FEdgeList.Count-1 do Edges[pi].frequent:=0;//流量统计清零
  for pi:=0 to FNodeList.Count-1 do Arr[pi]:=0;
  for pi:=0 to FNodeList.Count-1 do
    begin
      GetDistance(Nodes[pi]);
      for pj:=0 to FNodeList.Count-1 do
        begin
          if pj=pi then continue;
          if Nodes[pj].path.Count<2 then continue;
          for pk:=0 to Nodes[pj].path.Count-1 do
            begin
              tmp:=TTC2_Edge(Nodes[pj].path[pk]).nodes[0].id;
              if tmp<>pi then Arr[tmp]+=1/Nodes[pj].pathcount;
            end;
        end;
    end;
  for pi:=0 to FNodeList.Count-1 do
    begin
      Arr[pi]:=Arr[pi]/(V-2)/(V-1);
      Nodes[pi].CalcResult:=Arr[pi];
    end;
end;

procedure TTC2_Network.DistanceTest(index:integer;var arr:pdouble);
var pi,V:integer;
    tmpEdge:Pointer;
begin
  GetDistance(Nodes[index]);
  V:=FNodeList.Count;
  for pi:=0 to FNodeList.Count-1 do
    begin
      Arr[pi]:=Nodes[pi].distance;
    end;
end;

procedure TTC2_Network.BuildODAsBlock;
var a1,a2:longint;
begin
  ClearODs;
  for a1:=0 to ActorCount-1 do
    begin
      for a2:=0 to a1-1 do
        begin
          AddOD(Actors[a1],Actors[a2]);
        end;
      for a2:=a1+1 to ActorCount-1 do
        begin
          AddOD(Actors[a1],Actors[a2]);
        end;
    end;
end;
procedure TTC2_Network.BuildODAsRandom(possibility:double);
var a1,a2:longint;
begin
  Randomize;
  ClearODs;
  for a1:=0 to ActorCount-1 do
    begin
      for a2:=0 to ActorCount-1 do
        begin
          if a1=a2 then continue;
          if Random<possibility then AddOD(Actors[a1],Actors[a2]);
        end;
    end;
end;

function TTC2_Network.ODTest(actor1,actor2:TTC2_Actor{:integer}):double;
var n11,n12,n21,n22:TTC2_Node;
    a1,a2:TTC2_Actor;
    d1,d2,d_min:double;
    paths:TList;
    pathcount,pi:integer;
    procedure UpdateIfLess(n:TTC2_Node);
    begin
      if n.distance<d_min then
        begin
          paths.Clear;
          paths.AddList(n.path);
          pathcount:=n.pathcount;
          d_min:=n.distance;
        end
      else if n.distance=d_min then
        begin
          paths.AddList(n.path);
          pathcount+=n.pathcount;
        end;
    end;

begin

  //a1:=Actors[actor1];
  //a2:=Actors[actor2];
  a1:=actor1;
  a2:=actor2;
  n11:=a1.edge.nodes[0];
  n12:=a1.edge.nodes[1];
  n21:=a2.edge.nodes[0];
  n22:=a2.edge.nodes[1];

  pathcount:=0;
  d_min:=MAX_DOUBLE;
  paths:=TList.Create;
  try

    FindDistance(n11,n21);
    UpdateIfLess(n21);
    FindDistance(n11,n22);
    UpdateIfLess(n22);
    FindDistance(n12,n21);
    UpdateIfLess(n21);
    FindDistance(n12,n22);
    UpdateIfLess(n22);

    FindDistance(n21,n11);
    UpdateIfLess(n11);
    FindDistance(n21,n12);
    UpdateIfLess(n12);
    FindDistance(n22,n11);
    UpdateIfLess(n11);
    FindDistance(n22,n12);
    UpdateIfLess(n12);

    ZeroizeEdgeFrequent;
    for pi:=0 to paths.Count-1 do
      begin
        TTC2_Edge(paths[pi]).frequent:=1/pathcount;
      end;

  finally
    paths.Free;
  end;
  result:=d_min;

end;

procedure TTC2_Network.ODFrequency(Sender:TObject);//太慢了//好些了？
var arr:pdouble;
    e,pos,max:integer;
    tmpOD:Pointer;
begin
  arr:=GetMem(EdgeCount*8);
  for e:=0 to EdgeCount-1 do arr[e]:=0;
  try

    //for a1:=0 to ActorCount-1 do
      //for a2:=a1+1 to ActorCount-1 do
    for tmpOD in FActorOD do
      begin
        with TTC2_ActorOD(tmpOD) do distance:=ODTest(actors[0],actors[1]);
        for e:=0 to EdgeCount-1 do arr[e]+=Edges[e].frequent;
        with Sender as TAufScript do
          begin
            if Func_process.mid<>nil then Func_process.mid(Sender as TAufScript);
            if PSW.haltoff then exit;
          end;
      end;
    FrequencySum(true);
    for e:=0 to EdgeCount-1 do Edges[e].frequent:=arr[e];
  finally
    Freemem(arr,EdgeCount*8);
  end;

end;

procedure TTC2_Network.ActorEdgeUpdate(Sender:TObject;func:pFuncStr=nil);
var pi,pj:integer;
    actor:TTC2_Actor;
    edge:TTC2_Edge;
    dtmp,cos1,cos2:double;
    get_dist_result:array[0..1] of double;
    function get_dist(actor_x,actor_y,n1_x,n1_y,n2_x,n2_y:double):double;
    var len,d1,d2,p,s:double;
    begin
      len:=sqrt(sqr(n1_x-n2_x)+sqr(n1_y-n2_y));
      d1:=sqrt(sqr(n1_x-actor_x)+sqr(n1_y-actor_y));
      d2:=sqrt(sqr(n2_x-actor_x)+sqr(n2_y-actor_y));
      p:=(len+d1+d2)/2;
      s:=sqrt(p*(p-len)*(p-d1)*(p-d2));
      cos1:=(sqr(d1)+sqr(len)-sqr(d2))/d1/len/2;
      cos2:=(sqr(d2)+sqr(len)-sqr(d1))/d2/len/2;

      if (cos1>0) and (cos2>0) then
        begin
          result:=2*s/len;
        end
      else
        begin
          result:=d1;
          if d2<result then result:=d2;
        end;

      get_dist_result[0]:=0;//暂时不计算边内距离
      get_dist_result[1]:=0;//暂时不计算边内距离

    end;

begin
  for pi:=0 to FActorList.Count-1 do
    begin
      actor:=Actors[pi];
      actor.distance:=MAX_DOUBLE;
      for pj:=0 to FEdgeList.Count-1 do
        begin
          edge:=Edges[pj];
          dtmp:=get_dist(
            actor.latlong.x,
            actor.latlong.y,
            edge.nodes[0].latlong.x,
            edge.nodes[0].latlong.y,
            edge.nodes[1].latlong.x,
            edge.nodes[1].latlong.y
          );
          if dtmp<actor.distance then begin
            actor.distance:=dtmp;
            actor.node_distance[0]:=get_dist_result[0];
            actor.node_distance[1]:=get_dist_result[1];
            actor.edge:=edge;
          end;
        end;
      //func(Sender,'Actor "'+actor.name+'" - Edge ['+IntToStr(actor.edge.id)+']');
    end;
end;

procedure TTC2_Network.GetMaxMinXY(var min_x,min_y,max_x,max_y:double);
var pi:integer;
    tx,ty:double;
begin
  min_x:=MAX_DOUBLE;
  min_y:=MAX_DOUBLE;
  max_x:=MIN_DOUBLE;
  max_y:=MIN_DOUBLE;
  for pi:=0 to NodeCount-1 do
    begin
      tx:=Nodes[pi].pos.x;
      ty:=Nodes[pi].pos.y;
      if tx>max_x then max_x:=tx;
      if tx<min_x then min_x:=tx;
      if ty>max_y then max_y:=ty;
      if ty<min_y then min_y:=ty;
    end;
  for pi:=0 to ActorCount-1 do
    begin
      tx:=Actors[pi].pos.x;
      ty:=Actors[pi].pos.y;
      if tx>max_x then max_x:=tx;
      if tx<min_x then min_x:=tx;
      if ty>max_y then max_y:=ty;
      if ty<min_y then min_y:=ty;
    end;
end;


{ TPaintOption }
constructor TPaintOption.Create;
begin
  Inherited Create;
  Node.LabelOption.LabelFont:=TFont.Create;
  Edge.LabelOption.LabelFont:=TFont.Create;
  Actor.LabelOption.LabelFont:=TFont.Create;
  OD.LabelOption.LabelFont:=TFont.Create;
end;

destructor TPaintOption.Destroy;
begin
  Node.LabelOption.LabelFont.Free;
  Edge.LabelOption.LabelFont.Free;
  Actor.LabelOption.LabelFont.Free;
  OD.LabelOption.LabelFont.Free;
  Inherited Destroy;
end;

end.

