{
  Copyright (C) 2013-2018 Tim Sinaeve tim.sinaeve@gmail.com

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

unit ts.Editor.HTMLView.Settings;

{$MODE DELPHI}

interface

uses
  Classes, SysUtils;

const
  DEFAULT_WIDTH = 400;

type
  THTMLViewSettings = class(TComponent)
  private
    FWidth: Integer;
  public
    procedure AfterConstruction; override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure Assign(Source: TPersistent); override;

  published
    property Width: Integer
      read FWidth write FWidth default DEFAULT_WIDTH;
  end;

implementation

{$REGION 'construction and destruction'}
procedure THTMLViewSettings.AfterConstruction;
begin
  inherited AfterConstruction;
  FWidth := DEFAULT_WIDTH;
end;
{$ENDREGION}

{$REGION 'public methods'}
procedure THTMLViewSettings.AssignTo(Dest: TPersistent);
var
  S: THTMLViewSettings;
begin
  if Dest is THTMLViewSettings then
  begin
    S := THTMLViewSettings(Dest);
    S.Width := Width;
  end
  else
    inherited AssignTo(Dest);
end;

procedure THTMLViewSettings.Assign(Source: TPersistent);
var
  S: THTMLViewSettings;
begin
  if Source is THTMLViewSettings then
  begin
    S := THTMLViewSettings(Source);
    Width := S.Width;
  end
  else
    inherited Assign(Source);
end;
{$ENDREGION}

initialization
  RegisterClass(THTMLViewSettings);

end.


