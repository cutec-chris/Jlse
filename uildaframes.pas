unit uILDAFrames;

{$mode delphi}

interface

uses
  Classes, SysUtils, uLaserFrames;

type
  { TILDAFrame }

  TILDAFrame = class(TLaserFrame)
  protected
    FFrameType : byte;
    FNumberOfEntrys : word;
  public
    CompanyName : string;
    function Add: TLaserPoint; override;
    function LoadFromStream(aStream: TStream): Boolean; override;
    procedure LoadColorPalette(aStream : TStream);
  end;

  { TILDAPoint }

  TILDAPoint = class(TLaserPoint)
  public
    Is3D : Boolean;
    Z : word;
    constructor Create;override;
    function LoadFromStream(aStream: TStream): Boolean; override;
  end;

  { TILDAFrames }

  TILDAFrames = class(TLaserFrames)
  public
    constructor Create; override;
    function Add: TLaserFrame; overload; override;
    function LoadHeaderFromStream(aStream: TStream): Boolean;override;
  end;

implementation

{ TILDAPoint }

constructor TILDAPoint.Create;
begin
  inherited Create;
  Is3D:=False;
end;

function TILDAPoint.LoadFromStream(aStream: TStream): Boolean;
var
  status,color : byte;
  Blanking: Boolean;
  si : SmallInt;
begin
  Result := True;
  aStream.Read(si,2);
  x := BEtoN(si);
  aStream.Read(si,2);
  y := BEtoN(si);
  if TILDAFrame(Parent).FFrameType = 0 then //3d Point
    begin
      aStream.Read(si,2);
      z := BEtoN(si);
      Is3D := True;
    end;
  aStream.Read(status,1);
  aStream.Read(color,1);
  Blanking := (Status and $40 = $40);
  Result := not (Status and $80 = $80); // Last Point
end;

{ TILDAFrames }

constructor TILDAFrames.Create;
begin
  inherited Create;
  FrameWidth:=$FFFF div 2;
  FrameMiddle:=0;
end;

function TILDAFrames.Add: TLaserFrame;
begin
  Result:=TILDAFrame.Create;
  Result.Parent:=Self;
  Add(Result);
end;

function TILDAFrames.LoadHeaderFromStream(aStream: TStream): Boolean;
begin
  OldPointCount := 0;
  Clear;
end;

{ TILDAFrame }

function TILDAFrame.Add: TLaserPoint;
begin
  Result:=TILDAPoint.Create;
  Result.Parent:=Self;
  Points.Add(Result);
end;

function TILDAFrame.LoadFromStream(aStream: TStream): Boolean;
var
  s1: array[1..4] of char;
  s2: array[1..8] of char;
  b : byte;
  w : word;
  aPoint: TILDAPoint;
  aEntry: Integer;
begin
  Result := True;
  if aStream.Size > 5 then
    begin
      //ILDA
      aStream.Read(s1,4);
      //Unused
      aStream.Read(b,1);
      aStream.Read(b,1);
      aStream.Read(b,1);
      //Frame Type
      aStream.Read(b,1);
      FFrameType := b;
      if not (s1 = 'ILDA') then Result := False;
    end
  else Result := False;
  if not Result then exit;
  // frame name
  aStream.Read(s2,8);
  FrameName := s2;
  aStream.Read(s2,8);
  CompanyName := s2;
  aStream.Read(w,2);
  w := BEtoN(w);
  FNumberOfEntrys := w;
  aStream.Read(w,2);//Frame Number
  w := BEtoN(w);
  aStream.Read(w,2);//Total Number of Frames
  w := BEtoN(w);
  aStream.Read(b,1);//ScannerHead
  aStream.Read(b,1);//unused
  if FFrameType=2 then//Color Palette
    LoadColorPalette(aStream)
  else if FNumberOfEntrys>0 then
    begin
      aEntry := 0;
      aPoint := TILDAPoint.Create;
      aPoint.Parent:=Self;
      Points.Add(aPoint);
      while (aPoint.LoadFromStream(aStream)) and (aEntry<FNumberOfEntrys) do
        begin
          inc(aEntry);
          aPoint := TILDAPoint.Create;
          aPoint.Parent:=Self;
          Points.Add(aPoint);
        end;
      aPoint.Free;
    end;
end;

procedure TILDAFrame.LoadColorPalette(aStream: TStream);
var
  b : byte;
  i: Integer;
begin
  for i := 0 to FNumberOfEntrys-1 do
    begin
      aStream.Read(b,1);//r
      aStream.Read(b,1);//g
      aStream.Read(b,1);//b
    end;
end;

initialization
  FileFormats.Add('ild','ILDA Format',TILDAFrames,[fcLoad]);

end.
