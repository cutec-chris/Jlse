unit uILDAFrames;

{$mode delphi}

interface

uses
  Classes, SysUtils, uLaserFrames;

type
  { TILDAFrame }

  TILDAFrame = class(TLaserFrame)
  public
    function Add: TLaserPoint; override;
  end;

  TILDAPoint = class(TLaserPoint)

  end;

  { TILDAFrames }

  TILDAFrames = class(TLaserFrames)
  public
    function Add: TLaserFrame; overload; override;
    function LoadHeaderFromStream(aStream: TStream): Boolean;override;
  end;

implementation

{ TILDAFrames }

function TILDAFrames.Add: TLaserFrame;
begin
  Result:=TILDAFrame.Create;
  Result.Parent:=Self;
  Points.Add(Result);
end;

function TILDAFrames.LoadHeaderFromStream(aStream: TStream): Boolean;
begin
  Result:=inherited LoadHeaderFromStream(aStream);
end;

{ TILDAFrame }

function TILDAFrame.Add: TLaserPoint;
begin
  Result:=TILDAPoint.Create;
  Result.Parent:=Self;
  Points.Add(Result);
end;

end.
