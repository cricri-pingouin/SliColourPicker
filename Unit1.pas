unit Unit1;

interface

uses
  Windows, Classes, Graphics, Controls, Forms, ExtCtrls, Math, StdCtrls,
  SysUtils, Clipbrd, Dialogs;

type
  TForm1 = class(TForm)
    lblRed: TLabel;
    lblGreen: TLabel;
    lblBlue: TLabel;
    lblInfo: TLabel;
    Panel1: TPanel;
    edtRD: TEdit;
    edtGD: TEdit;
    edtBD: TEdit;
    lblRGB: TLabel;
    edtRGB: TEdit;
    btnCopyRGB: TButton;
    lblHEX: TLabel;
    edtHEX: TEdit;
    btnCopyHEX: TButton;
    lblHSV: TLabel;
    edtHSV: TEdit;
    btnCopyHSV: TButton;
    lblCMYK: TLabel;
    edtCMYK: TEdit;
    btnCopyCMYK: TButton;
    lblHSL: TLabel;
    edtHSL: TEdit;
    btnCopyHSL: TButton;
    dlgColor: TColorDialog;
    btnPalette: TButton;
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GetColour();
    procedure CalculateValues();
    procedure btnCopyRGBClick(Sender: TObject);
    procedure btnCopyHEXClick(Sender: TObject);
    procedure btnCopyHSVClick(Sender: TObject);
    procedure btnCopyCMYKClick(Sender: TObject);
    procedure edtRDChange(Sender: TObject);
    procedure edtGDChange(Sender: TObject);
    procedure edtBDChange(Sender: TObject);
    procedure btnCopyHSLClick(Sender: TObject);
    procedure btnPaletteClick(Sender: TObject);
  private
    FCaptured: Boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  //RGB
  R, G, B: Integer;

implementation

{$R *.dfm}
{$X+}
//{$H+}

const  // the first item, the place where the crosshair is
  ClickRect: TRect = (
    Left: 8;
    Top: 10;
    Right: 50;
    Bottom: 50;
  );

function DesktopColor(const X, Y: Integer): TColor;
var
  c: TCanvas;
begin
  c := TCanvas.Create;
  try
    c.Handle := GetWindowDC(GetDesktopWindow);
    Result := GetPixel(c.Handle, X, Y);
  finally
    c.Free;
  end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  //Draw the control and the crosshair if no capturing
  if GetCapture <> Handle then
  begin
    DrawFrameControl(Canvas.Handle, ClickRect, 0, DFCS_BUTTONPUSH);
    DrawIcon(Canvas.Handle, ClickRect.Left, ClickRect.Top, Screen.Cursors[crCross]);
  end;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (Shift = [ssLeft]) and PtInRect(ClickRect, Point(X, Y)) then
  begin
    DrawFrameControl(Canvas.Handle, ClickRect, 0, DFCS_PUSHED);
    FCaptured := True;
    SetCapture(Handle);
    Screen.Cursor := crCross;
  end;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FCaptured then
  begin
    FCaptured := False;
    ReleaseCapture;
    InvalidateRect(Handle, @ClickRect, False);
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FCaptured then
    GetColour;
end;

procedure TForm1.GetColour();
var
  Pos: TPoint;
  ThisColour: TColor;
begin
  //Get pixel colour
  GetCursorPos(Pos);
  ThisColour := DesktopColor(Pos.X, Pos.Y);
  //RGB
  R := ThisColour and $FF;
  G := (ThisColour and $FF00) shr 8;
  B := (ThisColour and $FF0000) shr 16;
  CalculateValues;
end;

procedure TForm1.CalculateValues();
var
  //CMYK
  C, M, Y, Rp, Gp, Bp, Kp: Single;
  //HSV
  RGBmin, RGBmax, RGBdelta, H, S, V: Single;
  //HSL
  Lum, Hue, Sat: Single;
begin
  Panel1.Color := R + G shl 8 + B shl 16;
  edtRD.Text := IntToStr(R);
  edtGD.Text := IntToStr(G);
  edtBD.Text := IntToStr(B);
  //Normalised values for CMYK and HSL
  Rp := R / 255;
  Gp := G / 255;
  Bp := B / 255;
  //CMYK
  Kp := 1 - Max(Rp, Max(Gp, Bp));
  if (Kp = 1) then
  begin
    C := 0;
    M := 0;
    Y := 0;
  end
  else
  begin
    C := (1 - Rp - Kp) / (1 - Kp);
    M := (1 - Gp - Kp) / (1 - Kp);
    Y := (1 - Bp - Kp) / (1 - Kp);
  end;
  //HSV and HSL
  RGBmin := Min(Min(R, G), B);
  RGBmax := Max(Max(R, G), B);
  RGBdelta := RGBmax - RGBmin;
  //HSV
  H := 0.0;
  V := RGBmax;
  if (RGBmin = RGBmax) then
  begin
    H := 0.0;
    S := 0.0;
  end
  else
  begin
    if (RGBmax > 0) then
      S := 255.0 * RGBdelta / RGBmax
    else
      S := 0.0;
    if (S <> 0.0) then
    begin
      if R = RGBmax then
        H := (G - B) / RGBdelta
      else if G = RGBmax then
        H := 2.0 + (B - R) / RGBdelta
      else if B = RGBmax then
        H := 4.0 + (R - G) / RGBdelta
    end
    else
      H := -1.0;
    H := H * 60;
    if H < 0.0 then
      H := H + 360.0;
  end;
  //HSL
  Lum := (RGBmax + RGBmin) / 510; //Average normalised, = / 2 / 255
  if (RGBmin = RGBmax) then
    Sat := 0.0
  else
     Sat := RGBdelta / 255  / (1 - Abs(2 * Lum - 1));
  Sat := Round(Sat * 100);
  Lum := Round(Lum * 100);
  Hue := H;
  //Copyable values
  edtRGB.Text := 'RGB(' + edtRD.Text + ',' + edtGD.Text + ',' + edtBD.Text + ')';
  edtHEX.Text := '#' + IntToHex(R, 2) + IntToHex(G, 2) + IntToHex(B, 2);
  edtHSV.Text := 'HSV(' + IntToStr(Round(H)) + ',' + IntToStr(Round(S * 100 / 255)) + ',' + IntToStr(Round(V * 100 / 255)) + ')';
  edtHSL.Text := 'HSL(' + IntToStr(Round(Hue)) + ',' + IntToStr(Round(Sat)) + ',' + IntToStr(Round(Lum)) + ')';
  edtCMYK.Text := 'CMYK(' + IntToStr(Round(C * 100)) + ',' + IntToStr(Round(M * 100)) + ',' + IntToStr(Round(Y * 100)) + ',' + IntToStr(Round(Kp * 100)) + ')';
end;

procedure TForm1.edtRDChange(Sender: TObject);
begin
  try
    StrToInt(edtRD.Text);
  except
    Exit;
  end;
  R := StrToInt(edtRD.Text);
  CalculateValues;
end;

procedure TForm1.edtGDChange(Sender: TObject);
begin
  try
    StrToInt(edtGD.Text);
  except
    Exit;
  end;
  G := StrToInt(edtGD.Text);
  CalculateValues;
end;

procedure TForm1.edtBDChange(Sender: TObject);
begin
  try
    StrToInt(edtBD.Text);
  except
    Exit;
  end;
  B := StrToInt(edtBD.Text);
  CalculateValues;
end;

procedure TForm1.btnCopyRGBClick(Sender: TObject);
begin
  Clipboard.AsText := edtRGB.Text;
end;

procedure TForm1.btnCopyHEXClick(Sender: TObject);
begin
  Clipboard.AsText := edtHEX.Text;
end;

procedure TForm1.btnCopyHSLClick(Sender: TObject);
begin
  Clipboard.AsText := edtHSL.Text;
end;

procedure TForm1.btnCopyHSVClick(Sender: TObject);
begin
  Clipboard.AsText := edtHSV.Text;
end;

procedure TForm1.btnCopyCMYKClick(Sender: TObject);
begin
  Clipboard.AsText := edtCMYK.Text;
end;

procedure TForm1.btnPaletteClick(Sender: TObject);
var
  MyColour: TColor;
begin
  dlgColor.Color := R + G shl 8 + B shl 16;
  if dlgColor.Execute then
    MyColour := dlgColor.Color
  else
    Exit;
  R := MyColour and $FF;
  G := (MyColour and $FF00) shr 8;
  B := (MyColour and $FF0000) shr 16;
  CalculateValues;
end;

end.
