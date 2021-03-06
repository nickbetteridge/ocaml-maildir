module IO : Maildir.IO with type +'a t = 'a
module FS : Maildir.FS with type key = Fpath.t

type fs

val fs : int -> fs

val root : Fpath.t
(** [root] is the root path of [Maildir_mem]. *)

val gettime : unit -> int64
(** [gettime ()] is the equivalent of [gettimeofday] of the fake file-system
    [Maildir_mem]. *)

type ('a, 'b) transmit = fs -> ('a, 'b) result
(** Type of transmit process. *)

val transmit : fs -> Fpath.t -> Fpath.t -> (unit, Rresult.R.msg) result
(** [transmit a b] creates a process which transmits contents of [a] to [b]. *)

val verify : fs -> Maildir.t -> bool
(** [verify fs] verifies that [fs] is a {i maildir}. *)

val add : fs -> Maildir.t -> time:int64 -> (Fpath.t -> ('ok, 'err) transmit) -> ('ok, 'err) result
(** [add fs t ~time transmit] adds a new message to Maildir folders [t].
    [transmit] is the process to transmit contents of message to [tmp] folder.
    At the end of [transmit] process, [message] is moved to [new] folder as a
    new message (atomic operation). *)

val scan_only_new : ('a -> Maildir.message Maildir.with_raw -> 'a) -> 'a -> fs -> Maildir.t -> 'a
(** [scan_only_new process acc fs t] scans only new messages in [t]. *)

val fold : ('a -> Maildir.message Maildir.with_raw -> 'a) -> 'a -> fs -> Maildir.t -> 'a
(** [fold process acc fs t] scans messages [cur]rent and [new] messages in [t]. *)

val get : Maildir.t -> Maildir.message Maildir.with_raw -> Fpath.t
(** [get t message] returns location of [message] in [t]. *)

val remove : fs -> Maildir.t -> Maildir.message Maildir.with_raw -> unit
(** [remove fs t message] removes [message] from [t] and [fs]. *)

val commit : fs -> Maildir.t -> ?flags:Maildir.flag list -> Maildir.message Maildir.with_raw -> unit

val get_flags : fs -> Maildir.t -> Maildir.message Maildir.with_raw -> Maildir.flag list
(** [get_flags fs t message] returns flags of [message] available in [t] and [fs]. *)

val set_flags : fs -> Maildir.t -> Maildir.message Maildir.with_raw -> Maildir.flag list -> unit
(** [set_flags fs t messages flags] sets flags of [message] in [t] and [fs] to [flags]. *)
