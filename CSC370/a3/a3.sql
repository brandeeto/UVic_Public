--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: campaign; Type: TABLE; Schema: public; Owner: c370_s17; Tablespace: 
--

CREATE TABLE campaign (
    name text NOT NULL,
    start_date text NOT NULL,
    phase integer NOT NULL,
    cost integer NOT NULL,
    fundraising integer,
    duration text NOT NULL,
    on_website boolean
);


ALTER TABLE public.campaign OWNER TO c370_s17;

--
-- Name: donor; Type: TABLE; Schema: public; Owner: c370_s17; Tablespace: 
--

CREATE TABLE donor (
    name text NOT NULL,
    donation integer NOT NULL
);


ALTER TABLE public.donor OWNER TO c370_s17;

--
-- Name: event; Type: TABLE; Schema: public; Owner: c370_s17; Tablespace: 
--

CREATE TABLE event (
    name text NOT NULL,
    start_date text NOT NULL,
    duration text NOT NULL,
    cost integer NOT NULL,
    location text NOT NULL,
    fundraising integer,
    part_of text NOT NULL
);


ALTER TABLE public.event OWNER TO c370_s17;

--
-- Name: eight; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW eight AS
 SELECT event.cost,
    event.name
   FROM event
  WHERE (event.part_of = 'Crude is Cruel'::text);


ALTER TABLE public.eight OWNER TO c370_s17;

--
-- Name: expenses; Type: TABLE; Schema: public; Owner: c370_s17; Tablespace: 
--

CREATE TABLE expenses (
    paid_to_volunteer text,
    paid_to_campaign text,
    amount_out integer NOT NULL
);


ALTER TABLE public.expenses OWNER TO c370_s17;

--
-- Name: five; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW five AS
 SELECT event.name,
    max(event.cost) AS max
   FROM event
  GROUP BY event.name
 HAVING (max(event.cost) < 10000);


ALTER TABLE public.five OWNER TO c370_s17;

--
-- Name: people; Type: TABLE; Schema: public; Owner: c370_s17; Tablespace: 
--

CREATE TABLE people (
    name text NOT NULL,
    tier integer NOT NULL,
    supporter boolean,
    salary integer
);


ALTER TABLE public.people OWNER TO c370_s17;

--
-- Name: four; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW four AS
 SELECT people.name,
    people.salary
   FROM people
  WHERE (people.salary = ( SELECT max(people_1.salary) AS max
           FROM people people_1));


ALTER TABLE public.four OWNER TO c370_s17;

--
-- Name: funding; Type: TABLE; Schema: public; Owner: c370_s17; Tablespace: 
--

CREATE TABLE funding (
    amount_in integer NOT NULL,
    from_campaign text,
    from_people text,
    from_donor text
);


ALTER TABLE public.funding OWNER TO c370_s17;

--
-- Name: nine; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW nine AS
 SELECT event.name,
    event.start_date
   FROM (event
  CROSS JOIN campaign)
  WHERE (event.start_date = campaign.start_date);


ALTER TABLE public.nine OWNER TO c370_s17;

--
-- Name: running; Type: TABLE; Schema: public; Owner: c370_s17; Tablespace: 
--

CREATE TABLE running (
    campaign_name text NOT NULL,
    worker_name text NOT NULL
);


ALTER TABLE public.running OWNER TO c370_s17;

--
-- Name: one; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW one AS
 SELECT people.name,
    people.salary
   FROM people,
    running
  WHERE ((running.campaign_name = 'Crude is Cruel'::text) AND (running.worker_name = people.name));


ALTER TABLE public.one OWNER TO c370_s17;

--
-- Name: seven; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW seven AS
 SELECT funding.from_campaign,
    funding.from_people,
    funding.from_donor
   FROM funding
  ORDER BY funding.amount_in;


ALTER TABLE public.seven OWNER TO c370_s17;

--
-- Name: six; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW six AS
 SELECT event.name
   FROM event
  WHERE (event.location ~~ 'Vic%'::text);


ALTER TABLE public.six OWNER TO c370_s17;

--
-- Name: ten; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW ten AS
 SELECT expenses.paid_to_volunteer,
    expenses.amount_out,
    funding.amount_in
   FROM (expenses
  CROSS JOIN funding)
  WHERE (expenses.paid_to_volunteer = funding.from_people);


ALTER TABLE public.ten OWNER TO c370_s17;

--
-- Name: three; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW three AS
 SELECT donor.name
   FROM (donor
   JOIN people USING (name));


ALTER TABLE public.three OWNER TO c370_s17;

--
-- Name: two; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW two AS
 SELECT running.worker_name
   FROM running,
    ( SELECT people.name
           FROM people
          WHERE (people.salary < 1000)) ss
  WHERE ((running.worker_name = ss.name) AND (running.campaign_name = 'Start Today, Save Tomorrow'::text));


ALTER TABLE public.two OWNER TO c370_s17;

--
-- Data for Name: campaign; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY campaign (name, start_date, phase, cost, fundraising, duration, on_website) FROM stdin;
The Greener Good	09/02/2014	1	20000	12000	3 weeks	t
Crude is Cruel	07/27/2014	1	13000	25000	2 weeks	f
Start Today, Save Tomorrow	06/01/2014	2	80000	55000	2 months	t
\.


--
-- Data for Name: donor; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY donor (name, donation) FROM stdin;
Bill	15000
Bob	500
PnG Corp.	25000
Omega inc.	22000
Linda	15000
\.


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY event (name, start_date, duration, cost, location, fundraising, part_of) FROM stdin;
Green Is Good	09/02/2014	1.5 weeks	10000	Central Park Burnaby	6000	The Greener Good
Protect Our Forests	09/11/2014	1.5 weeks	10000	Victoria Government House	6000	The Greener Good
Protect Our Waters	07/27/2014	1 week	5000	Shawnigan Lake	20000	Crude is Cruel
Stop The Crude	07/27/2014	2 week	8000	Victoria Harbour	5000	Crude is Cruel
For Generations to Come	06/01/2014	1 month	40000	Vancouver Harbour	25000	Start Today, Save Tomorrow
Protect The Beauty	06/19/2014	1 week	10000	Comox Valley	7000	Start Today, Save Tomorrow
Our Coast, Our Home	07/01/2014	3 weeks	5000	Tofino	23000	Start Today, Save Tomorrow
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY expenses (paid_to_volunteer, paid_to_campaign, amount_out) FROM stdin;
Jill	\N	500
Bran	\N	1000
Jay	\N	200
Leroy	\N	1000
\N	The Greener Good	20000
\N	Crude is Cruel	13000
\N	Start Today, Save Tomorrow	80000
\.


--
-- Data for Name: funding; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY funding (amount_in, from_campaign, from_people, from_donor) FROM stdin;
15000	\N	\N	Bill
500	\N	\N	Bob
25000	\N	\N	PnG Corp.
22000	\N	\N	Omega inc.
15000	\N	\N	Linda
12000	The Greener Good	\N	\N
13000	Crude is Cruel	\N	\N
80000	Start Today, Save Tomorrow	\N	\N
500	\N	Bran	\N
650	\N	Leroy	\N
100	\N	Jay	\N
\.


--
-- Data for Name: people; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY people (name, tier, supporter, salary) FROM stdin;
Jill	1	f	500
Linda	1	t	\N
Bran	2	f	1000
Matt	1	t	\N
Jay	1	f	200
Leroy	2	f	1000
Nick	2	f	\N
Cameron	1	t	\N
\.


--
-- Data for Name: running; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY running (campaign_name, worker_name) FROM stdin;
The Greener Good	Bran
Crude is Cruel	Bran
The Greener Good	Jill
Start Today, Save Tomorrow	Bran
Start Today, Save Tomorrow	Jay
Start Today, Save Tomorrow	Leroy
Start Today, Save Tomorrow	Nick
Crude is Cruel	Jill
Crude is Cruel	Jay
\.


--
-- Name: campaigns_name_key; Type: CONSTRAINT; Schema: public; Owner: c370_s17; Tablespace: 
--

ALTER TABLE ONLY campaign
    ADD CONSTRAINT campaigns_name_key UNIQUE (name);


--
-- Name: campaigns_start_date_key; Type: CONSTRAINT; Schema: public; Owner: c370_s17; Tablespace: 
--

ALTER TABLE ONLY campaign
    ADD CONSTRAINT campaigns_start_date_key UNIQUE (start_date);


--
-- Name: donor_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s17; Tablespace: 
--

ALTER TABLE ONLY donor
    ADD CONSTRAINT donor_pkey PRIMARY KEY (name);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s17; Tablespace: 
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (name);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s17; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (name);


--
-- Name: running_pkey; Type: CONSTRAINT; Schema: public; Owner: c370_s17; Tablespace: 
--

ALTER TABLE ONLY running
    ADD CONSTRAINT running_pkey PRIMARY KEY (campaign_name, worker_name);


--
-- Name: event_part_of_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s17
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_part_of_fkey FOREIGN KEY (part_of) REFERENCES campaign(name);


--
-- Name: expenses_paid_to_campaign_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s17
--

ALTER TABLE ONLY expenses
    ADD CONSTRAINT expenses_paid_to_campaign_fkey FOREIGN KEY (paid_to_campaign) REFERENCES campaign(name);


--
-- Name: expenses_paid_to_volunteer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s17
--

ALTER TABLE ONLY expenses
    ADD CONSTRAINT expenses_paid_to_volunteer_fkey FOREIGN KEY (paid_to_volunteer) REFERENCES people(name);


--
-- Name: funding_from_campaign_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s17
--

ALTER TABLE ONLY funding
    ADD CONSTRAINT funding_from_campaign_fkey FOREIGN KEY (from_campaign) REFERENCES campaign(name);


--
-- Name: funding_from_donor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s17
--

ALTER TABLE ONLY funding
    ADD CONSTRAINT funding_from_donor_fkey FOREIGN KEY (from_donor) REFERENCES donor(name);


--
-- Name: funding_from_people_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c370_s17
--

ALTER TABLE ONLY funding
    ADD CONSTRAINT funding_from_people_fkey FOREIGN KEY (from_people) REFERENCES people(name);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

