module Web.MVC.Widget

import Web.MVC

public export
record Widget where
  constructor MkWidget
  0 St : Type
  0 Ev : Type
  init : St
  setup : Cmd Ev
  update : Ev -> St -> St
  display : Ev -> St -> Cmd Ev

export
Semigroup Widget where
  w1 <+> w2 = MkWidget
    { St = (w1.St, w2.St)
    , Ev = Either w1.Ev w2.Ev
    , init = (w1.init, w2.init)
    , setup = batch
        [ Left <$> w1.setup
        , Right <$> w2.setup
        ]
    , update = \ev, (s1, s2) => case ev of
        Left  ev1 => (w1.update ev1 s1, s2)
        Right ev2 => (s1, w2.update ev2 s2)
    , display = \ev, (s1, s2) => case ev of
        Left ev  => Left <$> w1.display ev s1
        Right ev => Right <$> w2.display ev s2
    }

export
Monoid Widget where
  neutral = MkWidget
    { St = ()
    , Ev = Void
    , init = ()
    , setup = neutral
    , update = absurd
    , display = \_, _ => neutral
    }

export
runWidget : (JSErr -> IO ()) -> Widget -> IO ()
runWidget onError w = runMVC update display onError Nothing w.init
  where
    update : Maybe w.Ev -> w.St -> w.St
    update Nothing = id
    update (Just ev) = w.update ev

    display : Maybe w.Ev -> w.St -> Cmd (Maybe w.Ev)
    display ev s = Just <$> maybe (const w.setup) w.display ev s
