-- Run this entire file in Supabase SQL Editor.
create table if not exists public.locations (
  username text primary key,
  latitude double precision not null,
  longitude double precision not null,
  accuracy double precision,
  last_updated timestamptz not null default now(),
  is_online boolean not null default true
);

alter table public.locations enable row level security;

do $$
declare p record;
begin
  for p in select policyname from pg_policies where schemaname='public' and tablename='locations' loop
    execute format('drop policy if exists %I on public.locations', p.policyname);
  end loop;
end $$;

grant select on public.locations to authenticated;
create policy "admin_read_locations" on public.locations for select to authenticated using (true);

create or replace function public.set_location(
  p_username text,
  p_latitude double precision,
  p_longitude double precision,
  p_accuracy double precision default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_username is null or length(trim(p_username)) = 0 then raise exception 'username is required'; end if;
  if length(p_username) > 80 then raise exception 'username is too long'; end if;
  if p_latitude < -90 or p_latitude > 90 then raise exception 'invalid latitude'; end if;
  if p_longitude < -180 or p_longitude > 180 then raise exception 'invalid longitude'; end if;

  insert into public.locations(username,latitude,longitude,accuracy,last_updated,is_online)
  values(trim(p_username),p_latitude,p_longitude,p_accuracy,now(),true)
  on conflict (username) do update set
    latitude=excluded.latitude,
    longitude=excluded.longitude,
    accuracy=excluded.accuracy,
    last_updated=now(),
    is_online=true;
end;
$$;

revoke all on function public.set_location(text,double precision,double precision,double precision) from public;
grant execute on function public.set_location(text,double precision,double precision,double precision) to anon;
grant execute on function public.set_location(text,double precision,double precision,double precision) to authenticated;

do $$
begin
  alter publication supabase_realtime add table public.locations;
exception when duplicate_object then null;
end $$;
