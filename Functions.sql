create function paidAmount(@reservationId int)
returns int
as begin
    select sum(p.value) from Payments p where p.reservation_id=@reservationId group by p.reservation_id;
end

