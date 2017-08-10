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
    on_website text,
    annotation text
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
    part_of text NOT NULL,
    annotation text
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
    supporter text,
    salary integer,
    annotation text
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
    from_volunteer text,
    from_donor text
);


ALTER TABLE public.funding OWNER TO c370_s17;

--
-- Name: history; Type: TABLE; Schema: public; Owner: c370_s17; Tablespace: 
--

CREATE TABLE history (
    campaign_name text NOT NULL,
    volunteer_name text NOT NULL,
    annotation text
);


ALTER TABLE public.history OWNER TO c370_s17;

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
    volunteer_name text NOT NULL
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
  WHERE ((running.campaign_name = 'Crude is Cruel'::text) AND (running.volunteer_name = people.name));


ALTER TABLE public.one OWNER TO c370_s17;

--
-- Name: seven; Type: VIEW; Schema: public; Owner: c370_s17
--

CREATE VIEW seven AS
 SELECT funding.from_campaign,
    funding.from_volunteer AS from_people,
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
  WHERE (expenses.paid_to_volunteer = funding.from_volunteer);


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
 SELECT running.volunteer_name AS worker_name
   FROM running,
    ( SELECT people.name
           FROM people
          WHERE (people.salary < 1000)) ss
  WHERE ((running.volunteer_name = ss.name) AND (running.campaign_name = 'Start Today, Save Tomorrow'::text));


ALTER TABLE public.two OWNER TO c370_s17;

--
-- Data for Name: campaign; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY campaign (name, start_date, phase, cost, fundraising, duration, on_website, annotation) FROM stdin;
Crude is Cruel	07/27/2014	1	13000	25000	2 weeks	false	\N
Start Today, Save Tomorrow	06/01/2014	2	80000	55000	2 months	true	\N
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

COPY event (name, start_date, duration, cost, location, fundraising, part_of, annotation) FROM stdin;
Protect Our Waters	07/27/2014	1 week	5000	Shawnigan Lake	20000	Crude is Cruel	\N
Stop The Crude	07/27/2014	2 week	8000	Victoria Harbour	5000	Crude is Cruel	\N
For Generations to Come	06/01/2014	1 month	40000	Vancouver Harbour	25000	Start Today, Save Tomorrow	\N
Protect The Beauty	06/19/2014	1 week	10000	Comox Valley	7000	Start Today, Save Tomorrow	\N
Our Coast, Our Home	07/01/2014	3 weeks	5000	Tofino	23000	Start Today, Save Tomorrow	\N
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY expenses (paid_to_volunteer, paid_to_campaign, amount_out) FROM stdin;
Bran	\N	1000
Jay	\N	200
\N	Crude is Cruel	13000
\N	Start Today, Save Tomorrow	80000
\.


--
-- Data for Name: funding; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY funding (amount_in, from_campaign, from_volunteer, from_donor) FROM stdin;
15000	\N	\N	Bill
500	\N	\N	Bob
25000	\N	\N	PnG Corp.
22000	\N	\N	Omega inc.
15000	\N	\N	Linda
13000	Crude is Cruel	\N	\N
80000	Start Today, Save Tomorrow	\N	\N
500	\N	Bran	\N
100	\N	Jay	\N
\.


--
-- Data for Name: history; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY history (campaign_name, volunteer_name, annotation) FROM stdin;
The Greener Good	Bran	\N
Crude is Cruel	Bran	\N
Start Today, Save Tomorrow	Bran	\N
Start Today, Save Tomorrow	Jay	\N
Crude is Cruel	Jay	\N
The Greener Good	Jay	\N
The Greener Good	Nick	\N
Start Today, Save Tomorrow	Nick	\N
\.


--
-- Data for Name: people; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY people (name, tier, supporter, salary, annotation) FROM stdin;
Linda	1	true	\N	\N
Bran	2	false	1000	\N
Matt	1	true	\N	\N
Jay	1	false	200	\N
Nick	2	false	\N	\N
Cameron	1	true	\N	\N
\.


--
-- Data for Name: running; Type: TABLE DATA; Schema: public; Owner: c370_s17
--

COPY running (campaign_name, volunteer_name) FROM stdin;
The Greener Good	Bran
Crude is Cruel	Bran
The Greener Good	Nick
Start Today, Save Tomorrow	Nick
Start Today, Save Tomorrow	Bran
Start Today, Save Tomorrow	Jay
Crude is Cruel	Jay
The Greener Good	Jay
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
    ADD CONSTRAINT running_pkey PRIMARY KEY (campaign_name, volunteer_name);


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
    ADD CONSTRAINT funding_from_people_fkey FOREIGN KEY (from_volunteer) REFERENCES people(name);


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

