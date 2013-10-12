{
  Copyright (C) 2013 Tim Sinaeve tim.sinaeve@gmail.com

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

unit ts.Editor.Settings.CodeFilter;

{$MODE Delphi}

interface

uses
  Classes, SysUtils;

const
  DEFAULT_WIDTH = 400;

type

  { TCodeFilterSettings }

  TCodeFilterSettings = class(TPersistent)
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

{$region 'construction and destruction' /fold}
procedure TCodeFilterSettings.AfterConstruction;
begin
  inherited AfterConstruction;
end;
{$endregion}

{$region 'public methods' /fold}
procedure TCodeFilterSettings.AssignTo(Dest: TPersistent);
var
  S: TCodeFilterSettings;
begin
  if Dest is TCodeFilterSettings then
  begin
    S := TCodeFilterSettings(Dest);
    S.Width := Width;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TCodeFilterSettings.Assign(Source: TPersistent);
var
  S: TCodeFilterSettings;
begin
  if Source is TCodeFilterSettings then
  begin
    S := TCodeFilterSettings(Source);
    Width := S.Width;
  end
  else
    inherited Assign(Source);
end;
{$endregion}

end.


