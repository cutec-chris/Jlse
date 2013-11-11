unit upopelframes;

{$mode delphi}

interface

uses
  Classes, SysUtils, uLaserFrames;

type

  { TMOTFrame }

  TMOTFrame = class(TLaserFrame)
  protected
  public
    CompanyName : string;
    function Add: TLaserPoint; override;
    function LoadFromStream(aStream: TStream): Boolean; override;
  end;

  { TMOTPoint }

  TMOTPoint = class(TLaserPoint)
  public
    function LoadFromStream(aStream: TStream): Boolean; override;
  end;

  { TMOTFrames }

  TMOTFrames = class(TLaserFrames)
  private
    FBlankDelay: Integer;
    FPointDelay: Integer;
    FSL : TStringList;
    NumPoints: Integer;
  public
    constructor Create; override;
    destructor Destroy; reintroduce;
    property PointDelay : Integer read FPointDelay;
    property BlankDelay : Integer read FBlankDelay;
    function Add: TLaserFrame; overload; override;
    function LoadHeaderFromStream(aStream: TStream): Boolean;override;
    procedure LoadFromStream(aStream: TStream); override;
  end;

implementation

{ TMOTFrame }

function TMOTFrame.Add: TLaserPoint;
begin
  Result:=TMOTPoint.Create;
  Result.Parent:=Self;
end;

function TMOTFrame.LoadFromStream(aStream: TStream): Boolean;
begin
end;

function TMOTPoint.LoadFromStream(aStream: TStream): Boolean;
begin
end;

{ TMOTFrames }

constructor TMOTFrames.Create;
begin
  inherited Create;
  FSL := TStringList.Create;
end;

destructor TMOTFrames.Destroy;
begin
  FSL.Free;
end;

function TMOTFrames.Add: TLaserFrame;
begin
  Result:=TMOTFrame.Create(Self);
  Add(Result);
end;

{
150            point delay
0            blank delay
6            number of points
100
0000000000 0        [rotate left][hor mirror][vert mirror][rotate right] ... last digit: pump
10            pic delay
1
1
1
1
360            W max
1
1
1
1
1
1
1
1
1

021C9002504802985002849002589402646C [color][x][y] - last frame
...
021C9002504802985002849002589402646C [color][x][y] - first frame
}
function TMOTFrames.LoadHeaderFromStream(aStream: TStream): Boolean;
begin
  FPointDelay:=StrToIntDef(FSL[0],0);
  FBlankDelay:=StrToIntDef(FSL[1],0);
  NumPoints:=StrToIntDef(FSL[2],0);
end;

procedure TMOTFrames.LoadFromStream(aStream: TStream);
var
  i: Integer;
begin
  FSL.LoadFromStream(aStream);
  if FSL.Count<20 then exit;
  LoadHeaderFromStream(aStream);
  for i := 21 to FSL.Count-1 do
    begin

    end;
end;

initialization
  FileFormats.Add('mot','Popelscan Format',TMOTFrames,[fcLoad]);

end.

