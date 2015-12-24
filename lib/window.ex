defmodule Window do
  defstruct [:frame, :t_len, :canvas, :snake_pen, :field_brush, :snake_points]

  @behaiour :wx_object

  use Bitwise

  require Record
  Record.defrecord :wx, [:id, :obj, :userData, :event]
  Record.defrecord :wxClose, [:type]
  Record.defrecord :wxPaint, [:type]

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

  def start_link() do
    :wx_object.start_link(__MODULE__, [], [])
  end

  def show(object) do
    :wx_object.call(object, :show)
  end

  def draw(object, snake_points) do
    :wx_object.call(object, {:draw, snake_points})
  end

  def init([]) do
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

    :wxFrame.connect(f, :close_window)
    :wxPanel.connect(c, :paint, [:callback])

    {f, %Window{frame: f, t_len: t2, canvas: c, snake_pen: sp, field_brush: brush}}
  end

  def handle_call(:show, _from, win) do
    unless :wxWindow.isShown(win.frame) do
      true = :wxFrame.show(win.frame)
    end
    {:reply, :ok, win}
  end

  def handle_call({:draw, snake_points}, _from,  win) do
    :wxWindow.refresh win.canvas
    {:reply, :ok, %Window{win | snake_points: snake_points}}
  end

  def handle_event(wx(event: wxClose()), win) do
    {:stop, :normal, win}
  end

  def handle_sync_event(wx(event: wxPaint()), _wxObj, win) do
    dc = :wxPaintDC.new(win.canvas)
    {w, h} = :wxDC.getSize(dc)
    bmp = :wxBitmap.new(w, h)
    mdc = :wxMemoryDC.new(bmp)

    do_draw(win, win.snake_points, mdc)
    :wxDC.blit(dc, {0, 0}, {w, h}, mdc, {0, 0})

    :wxMemoryDC.destroy(mdc)
    :wxBitmap.destroy(bmp)
    :wxPaintDC.destroy(dc)
  end

  def handle_info(_msg, win), do: {:noreply, win}

  def terminate(_reason, win) do
    :wxFrame.destroy(win.frame)
    :wxPen.destroy(win.snake_pen)
    :wxBrush.destroy(win.field_brush)
  end

  def code_change(_, _, win), do: {:ok, win}

  defp do_draw(win, pp, dc) do
    :wxDC.setPen(dc, win.snake_pen)
    :wxDC.setBackground(dc, win.field_brush)
    :wxDC.clear(dc)
    :wxDC.drawLines(dc, pp)
  end
end
