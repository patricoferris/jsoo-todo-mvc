let ( let+ ) a f = Lwd.map ~f a
let ( and+ ) = Lwd.pair
let ( let* ) a f = Lwd.bind ~f a
let ( and* ) = Lwd.pair
