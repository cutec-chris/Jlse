unit ultfframes;

{$mode delphi}

interface

uses
  Classes, SysUtils, uLaserFrames;

type

  { TLTFFrame }

  TLTFFrame = class(TLaserFrame)
  protected
  public
    CompanyName : string;
    function Add: TLaserPoint; override;
    function LoadFromStream(aStream: TStream): Boolean; override;
  end;

  { TLTFPoint }

  TLTFPoint = class(TLaserPoint)
  public
    function LoadFromStream(aStream: TStream): Boolean; override;
  end;

  { TLTFFrames }

  TLTFFrames = class(TLaserFrames)
  public
    constructor Create; override;
    function Add: TLaserFrame; overload; override;
    function LoadHeaderFromStream(aStream: TStream): Boolean;override;
    procedure LoadFromStream(aStream: TStream); override;
    procedure ReadFrameData(aStream:TStream;TagLen:Cardinal);
  end;

implementation

{ TLTFFrame }

function TLTFFrame.Add: TLaserPoint;
begin
  Result:=TLTFPoint.Create;
  Result.Parent:=Self;
end;

function TLTFFrame.LoadFromStream(aStream: TStream): Boolean;
begin
end;

function TLTFPoint.LoadFromStream(aStream: TStream): Boolean;
begin
end;

{ TLTFFrames }

constructor TLTFFrames.Create;
begin
  inherited Create;
end;

function TLTFFrames.Add: TLaserFrame;
begin
  Result:=TLTFFrame.Create(Self);
  Add(Result);
end;

function TLTFFrames.LoadHeaderFromStream(aStream: TStream): Boolean;
var
  s1: array[1..3] of char;
  b : byte;
  u32 : Cardinal;
begin
  Result := True;
  Clear;
  if aStream.Size > 4 then
    begin
      aStream.Read(s1,3);
      aStream.Read(b,1);
      FileVersion := b;
      if not (s1 = 'LTF') then Result := False;
    end
  else Result := False;
  aStream.Read(u32,4);//Count of Tags
  aStream.Read(u32,4);//TagImage1count
  aStream.Read(u32,4);//reserved
end;

procedure TLTFFrames.LoadFromStream(aStream: TStream);
var
  TagId,b : byte;
  TagLen : Cardinal;
  aLen: Cardinal;
begin
  if not LoadHeaderFromStream(aStream) then exit;
  Repeat
    aStream.Read(TagId,1);
    aStream.Read(TagLen,1);
    if TagLen=255 then
      aStream.Read(TagLen,4);
    case Tagid of
    //TagColorTable  :ReadColorTable(aStream,TagLen);
    //TagHersteller  :ReadVendorData(aStream,TagLen);
    //TagImageName:  :ReadFrameName(aStream,TagLen);
    //TagSetPPS      :ReadPPS(aStream,TagLen);
    //TagImage1
    10:ReadFrameData(aStream,TagLen);
     else
       begin
         aLen := tagLen;
         while aLen>0 do
           begin
             aStream.Read(b,1);
             dec(aLen);
           end;
       end;
    end;
  until Tagid=TagEnd;
end;

procedure TLTFFrames.ReadFrameData(aStream: TStream; TagLen: Cardinal);
begin

end;

initialization
  FileFormats.Add('ltf','Laserimage Transfer Format',TLTFFrames,[fcLoad]);

end.

