--
-- PostgreSQL database dump
--

\restrict Z4WrMTohC6ezfKxiQhKdG1X7g8anW6VTd6mcsV2ljv2cgVgxsXQjlM4zKsFtyNR

-- Dumped from database version 17.11 (Debian 17.11-1.pgdg13+2)
-- Dumped by pg_dump version 17.11 (Debian 17.11-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: billing; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA billing;


ALTER SCHEMA billing OWNER TO postgres;

--
-- Name: sales; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sales;


ALTER SCHEMA sales OWNER TO postgres;

--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: touch_invoice(); Type: FUNCTION; Schema: billing; Owner: postgres
--

CREATE FUNCTION billing.touch_invoice() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN NEW.issued_on := COALESCE(NEW.issued_on, current_date); RETURN NEW; END $$;


ALTER FUNCTION billing.touch_invoice() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: invoices; Type: TABLE; Schema: billing; Owner: postgres
--

CREATE TABLE billing.invoices (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    issued_on date DEFAULT CURRENT_DATE NOT NULL,
    amount_cents integer NOT NULL
);


ALTER TABLE billing.invoices OWNER TO postgres;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: billing; Owner: postgres
--

CREATE SEQUENCE billing.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE billing.invoices_id_seq OWNER TO postgres;

--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: postgres
--

ALTER SEQUENCE billing.invoices_id_seq OWNED BY billing.invoices.id;


--
-- Name: payments; Type: TABLE; Schema: billing; Owner: postgres
--

CREATE TABLE billing.payments (
    id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    method text NOT NULL,
    captured_at timestamp with time zone
);


ALTER TABLE billing.payments OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: billing; Owner: postgres
--

CREATE SEQUENCE billing.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE billing.payments_id_seq OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: postgres
--

ALTER SEQUENCE billing.payments_id_seq OWNED BY billing.payments.id;


--
-- Name: customers; Type: TABLE; Schema: sales; Owner: postgres
--

CREATE TABLE sales.customers (
    id bigint NOT NULL,
    email text NOT NULL,
    country character(2) DEFAULT 'FR'::bpchar NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sales.customers OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: sales; Owner: postgres
--

CREATE SEQUENCE sales.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sales.customers_id_seq OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: postgres
--

ALTER SEQUENCE sales.customers_id_seq OWNED BY sales.customers.id;


--
-- Name: order_items; Type: TABLE; Schema: sales; Owner: postgres
--

CREATE TABLE sales.order_items (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    sku text NOT NULL,
    qty integer DEFAULT 1 NOT NULL,
    unit_cents integer NOT NULL
);


ALTER TABLE sales.order_items OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: sales; Owner: postgres
--

CREATE SEQUENCE sales.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sales.order_items_id_seq OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: postgres
--

ALTER SEQUENCE sales.order_items_id_seq OWNED BY sales.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: sales; Owner: postgres
--

CREATE TABLE sales.orders (
    id bigint NOT NULL,
    customer_id bigint NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    total_cents integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT orders_total_cents_check CHECK ((total_cents >= 0))
);


ALTER TABLE sales.orders OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: sales; Owner: postgres
--

CREATE SEQUENCE sales.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE sales.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: postgres
--

ALTER SEQUENCE sales.orders_id_seq OWNED BY sales.orders.id;


--
-- Name: v_order_totals; Type: VIEW; Schema: sales; Owner: postgres
--

CREATE VIEW sales.v_order_totals AS
 SELECT o.id,
    o.status,
    sum((oi.qty * oi.unit_cents)) AS total_cents
   FROM (sales.orders o
     JOIN sales.order_items oi ON ((oi.order_id = o.id)))
  GROUP BY o.id, o.status;


ALTER VIEW sales.v_order_totals OWNER TO postgres;

--
-- Name: invoices id; Type: DEFAULT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.invoices ALTER COLUMN id SET DEFAULT nextval('billing.invoices_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.payments ALTER COLUMN id SET DEFAULT nextval('billing.payments_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: sales; Owner: postgres
--

ALTER TABLE ONLY sales.customers ALTER COLUMN id SET DEFAULT nextval('sales.customers_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: sales; Owner: postgres
--

ALTER TABLE ONLY sales.order_items ALTER COLUMN id SET DEFAULT nextval('sales.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: sales; Owner: postgres
--

ALTER TABLE ONLY sales.orders ALTER COLUMN id SET DEFAULT nextval('sales.orders_id_seq'::regclass);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: sales; Owner: postgres
--

ALTER TABLE ONLY sales.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: sales; Owner: postgres
--

ALTER TABLE ONLY sales.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: sales; Owner: postgres
--

ALTER TABLE ONLY sales.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: order_items_order_idx; Type: INDEX; Schema: sales; Owner: postgres
--

CREATE INDEX order_items_order_idx ON sales.order_items USING btree (order_id);


--
-- Name: orders_customer_idx; Type: INDEX; Schema: sales; Owner: postgres
--

CREATE INDEX orders_customer_idx ON sales.orders USING btree (customer_id);


--
-- Name: orders_customer_idx_dup; Type: INDEX; Schema: sales; Owner: postgres
--

CREATE INDEX orders_customer_idx_dup ON sales.orders USING btree (customer_id);


--
-- Name: invoices invoices_touch; Type: TRIGGER; Schema: billing; Owner: postgres
--

CREATE TRIGGER invoices_touch BEFORE INSERT ON billing.invoices FOR EACH ROW EXECUTE FUNCTION billing.touch_invoice();


--
-- Name: invoices invoices_order_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.invoices
    ADD CONSTRAINT invoices_order_id_fkey FOREIGN KEY (order_id) REFERENCES sales.orders(id);


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES billing.invoices(id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: postgres
--

ALTER TABLE ONLY sales.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES sales.orders(id) ON DELETE CASCADE;


--
-- Name: orders orders_customer_fk; Type: FK CONSTRAINT; Schema: sales; Owner: postgres
--

ALTER TABLE ONLY sales.orders
    ADD CONSTRAINT orders_customer_fk FOREIGN KEY (customer_id) REFERENCES sales.customers(id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: postgres
--

ALTER TABLE ONLY sales.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES sales.customers(id);


--
-- PostgreSQL database dump complete
--

\unrestrict Z4WrMTohC6ezfKxiQhKdG1X7g8anW6VTd6mcsV2ljv2cgVgxsXQjlM4zKsFtyNR

