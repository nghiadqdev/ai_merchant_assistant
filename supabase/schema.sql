-- AI Merchant Assistant — Supabase schema
-- Run this in the Supabase SQL editor, then enable Anonymous sign-ins in
-- Authentication → Providers. The app uses auth.uid() for RLS.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- System benchmarks (read-only for clients; seeded below)
-- ---------------------------------------------------------------------------
create table if not exists public.system_benchmarks (
  id text primary key,
  category_name text not null,
  default_platform_fee double precision not null
    check (default_platform_fee between 0 and 1),
  default_ads_cost double precision not null
    check (default_ads_cost between 0 and 1),
  dynamic_risk_type text not null,
  default_risk_rate double precision not null
    check (default_risk_rate between 0 and 1)
);

alter table public.system_benchmarks enable row level security;

drop policy if exists "system_benchmarks are readable" on public.system_benchmarks;
create policy "system_benchmarks are readable"
  on public.system_benchmarks for select
  using (true);

-- ---------------------------------------------------------------------------
-- User profile
-- ---------------------------------------------------------------------------
create table if not exists public.user_business_profile (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  selected_category_id text not null
    references public.system_benchmarks(id),
  initial_capital double precision not null
    check (initial_capital >= 0),
  updated_at timestamptz not null default now()
);

alter table public.user_business_profile enable row level security;

drop policy if exists "own profile" on public.user_business_profile;
create policy "own profile"
  on public.user_business_profile for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Product simulations
-- ---------------------------------------------------------------------------
create table if not exists public.products_simulations (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  cogs double precision not null check (cogs >= 0),
  selling_price double precision not null check (selling_price >= 0),
  custom_ads_rate double precision not null
    check (custom_ads_rate between 0 and 1),
  custom_platform_fee double precision not null
    check (custom_platform_fee between 0 and 1),
  custom_risk_rate double precision not null
    check (custom_risk_rate between 0 and 1),
  packaging_fee double precision not null default 0
    check (packaging_fee >= 0),
  updated_at timestamptz not null default now()
);

alter table public.products_simulations enable row level security;

drop policy if exists "own products" on public.products_simulations;
create policy "own products"
  on public.products_simulations for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index if not exists products_simulations_user_id_idx
  on public.products_simulations(user_id);

-- ---------------------------------------------------------------------------
-- Daily expenses
-- ---------------------------------------------------------------------------
create table if not exists public.daily_expenses (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  type text not null
    check (type in ('ads', 'shipping', 'returns', 'surcharge')),
  amount double precision not null check (amount >= 0),
  note text not null default '',
  updated_at timestamptz not null default now()
);

alter table public.daily_expenses enable row level security;

drop policy if exists "own expenses" on public.daily_expenses;
create policy "own expenses"
  on public.daily_expenses for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index if not exists daily_expenses_user_date_idx
  on public.daily_expenses(user_id, date desc);

-- ---------------------------------------------------------------------------
-- Daily sales (extension needed by the 7-day revenue chart)
-- ---------------------------------------------------------------------------
create table if not exists public.daily_sales (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  revenue double precision not null check (revenue >= 0),
  units integer not null check (units >= 0),
  updated_at timestamptz not null default now()
);

alter table public.daily_sales enable row level security;

drop policy if exists "own sales" on public.daily_sales;
create policy "own sales"
  on public.daily_sales for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index if not exists daily_sales_user_date_idx
  on public.daily_sales(user_id, date desc);

-- ---------------------------------------------------------------------------
-- updated_at trigger
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'user_business_profile',
    'products_simulations',
    'daily_expenses',
    'daily_sales'
  ] loop
    execute format(
      'drop trigger if exists set_updated_at on public.%I',
      table_name
    );
    execute format(
      'create trigger set_updated_at before update on public.%I
       for each row execute function public.set_updated_at()',
      table_name
    );
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Seed benchmarks
-- ---------------------------------------------------------------------------
insert into public.system_benchmarks
  (id, category_name, default_platform_fee, default_ads_cost,
   dynamic_risk_type, default_risk_rate)
values
  ('fashion_01', 'Thời trang', 0.12, 0.15, 'Tỷ lệ hoàn hàng', 0.10),
  ('tech_02', 'Điện tử', 0.08, 0.10, 'Phí bảo hành', 0.05),
  ('cosmetics_03', 'Mỹ phẩm', 0.15, 0.20, 'Hàng hư hỏng', 0.08),
  ('food_04', 'Thực phẩm', 0.10, 0.12, 'Hao hụt', 0.06),
  ('home_05', 'Gia dụng', 0.11, 0.14, 'Bảo hành', 0.04),
  ('accessories_06', 'Phụ kiện', 0.13, 0.16, 'Đổi trả', 0.09)
on conflict (id) do update set
  category_name = excluded.category_name,
  default_platform_fee = excluded.default_platform_fee,
  default_ads_cost = excluded.default_ads_cost,
  dynamic_risk_type = excluded.dynamic_risk_type,
  default_risk_rate = excluded.default_risk_rate;
