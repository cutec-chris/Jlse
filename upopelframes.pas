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
  public
    constructor Create; override;
    function Add: TLaserFrame; overload; override;
    function LoadHeaderFromStream(aStream: TStream): Boolean;override;
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
end;

function TMOTFrames.Add: TLaserFrame;
begin
  Result:=TMOTFrame.Create(Self);
  Add(Result);
end;

function TMOTFrames.LoadHeaderFromStream(aStream: TStream): Boolean;
begin
end;

initialization
  FileFormats.Add('mot','Popelscan Format',TMOTFrames,[fcLoad]);

end.

