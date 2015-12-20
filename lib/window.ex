defmodule Window do
  defstruct [:frame, :t_len, :canvas, :snake_pen, :field_brush]

  use Bitwise
  require Snake

  @wxHORIZONTAL 4
  @wxVERTICAL 8

  @wxLEFT 16
  @wxRIGHT 32
  @wxUP 64
  @wxDOWN 128
  @wxALL @wxLEFT ||| @wxRIGHT ||| @wxUP ||| @wxDOWN

  @wxALIGN_CENTER 256 ||| 2048
  @wxEXPAND 8192
  @wxSHAPED 16384
  @wxFONTWEIGHT_BOLD 92

  @wxSOLID 100

  def new() do
    :wx.new()

    f = :wxFrame.new(:wx.null(), -1, 'Snake Game')

    t1 = :wxStaticText.new(f, -1, 'Snake Len:')
    fnt = :wxStaticText.getFont(t1)
    :wxFont.setWeight(fnt, @wxFONTWEIGHT_BOLD)
    :wxStaticText.setFont(t1, fnt)

    t2 = :wxStaticText.new(f, -1, '--')

    t3 = :wxStaticText.new(f, -1, 'bottom line')

    c = :wxPanel.new(f, [size: {200, 200}])
    :wxPanel.setBackgroundColour(c, {0, 255, 0})

    s = :wxBoxSizer.new(@wxVERTICAL)
    s_stat = :wxBoxSizer.new(@wxHORIZONTAL)
    :wxBoxSizer.add(s_stat, t1)
    :wxBoxSizer.addSpacer(s_stat, 3)
    :wxBoxSizer.add(s_stat, t2)
    :wxBoxSizer.add(s, s_stat, [proportion: 0, flag: @wxALIGN_CENTER ||| @wxALL, border: 5])
    :wxBoxSizer.add(s, c, [proportion: 1, flag: @wxSHAPED ||| @wxALIGN_CENTER])
    :wxBoxSizer.add(s, t3, [proportion: 0, flag: @wxALIGN_CENTER])
    :wxFrame.setSizer(f, s)

    sp = :wxPen.new({255, 255, 0}, [width: 3, style: @wxSOLID])
    brush = :wxBrush.new({0, 255, 0})

    %Window{frame: f, t_len: t2, canvas: c, snake_pen: sp, field_brush: brush}
  end

  def show(win) do
    if :wxWindow.isShown(win.frame) do
      {:error, :already_shown}
    else
      true = :wxFrame.show(win.frame)
    end
  end

  def destroy(win) do
    :wxFrame.destroy(win.frame)
    :wxPen.destroy(win.snake_pen)
    :wxBrush.destroy(win.field_brush)
  end

  def draw(win, snake = %Snake{}) do
    wdc = :wxClientDC.new(win.canvas)
    {w, h} = :wxDC.getSize(wdc)
    bmp = :wxBitmap.new(w, h)
    mdc = :wxMemoryDC.new(bmp)
    do_draw(win, points(snake), mdc)

    :wxDC.blit(wdc, {0, 0}, {w, h}, mdc, {0, 0})
    :wxClientDC.destroy(wdc)
    :wxMemoryDC.destroy(mdc)
    :wxBitmap.destroy(bmp)
  end

  def do_draw(win, pp, dc) do
    :wxDC.setPen(dc, win.snake_pen)
    :wxDC.setBackground(dc, win.field_brush)
    :wxDC.clear(dc)
    :wxDC.drawLines(dc, pp)
  end

  defp points(snake), do: [snake.h | Enum.reverse(snake.tail)]
end
