\LoadClass[11pt]{report}

\usepackage[spanish]{babel}
\selectlanguage{spanish}

\usepackage[a4paper,left=3cm,right=3cm,top=2.5cm,bottom=2.5cm]{geometry}

% Titlesec
\usepackage[explicit]{titlesec}

\titleformat{\chapter}[display]
{\bfseries\LARGE} % Format
{} % Label
{2ex} % Sep
{\titlerule % Before code
\vspace{1.5ex}
\filright
\parbox{0.666\textwidth}{#1}\parbox{0.333\textwidth}{\hfill\Huge\thechapter}}
[\vspace{1ex} % After code
\titlerule]
\titleformat{name=\chapter,numberless}[display]
{\bfseries\LARGE} % Format
{} % Label
{2ex} % Sep
{\titlerule % Before code
\vspace{1.5ex}
\filright
#1}
[\vspace{1ex} % After code
\titlerule]
\titlespacing*{\chapter}{0pt}{0pt}{40pt}

\usepackage{graphicx}

\newcommand{\tfgtitle}[1]{\newcommand{\tfgtitlevar}{#1}}
\newcommand{\tfgdegree}[1]{\newcommand{\tfgdegreevar}{#1}}
\newcommand{\tfgauthor}[1]{\newcommand{\tfgauthorvar}{#1}}
\newcommand{\tfgtutor}[1]{\newcommand{\tfgtutorvar}{#1}}
\newcommand{\tfgdepartment}[1]{\newcommand{\tfgdepartmentvar}{#1}}
\newcommand{\tfgdate}[1]{\newcommand{\tfgdatevar}{#1}}

\newcommand{\tfgmaketitle}{
\begin{titlepage}
	\begin{center}
		\bfseries
		\sffamily

		\includegraphics[scale=2.5]{images/us_logo}\\[0.4cm]

		{\normalsize ESCUELA T{\'E}CNICA SUPERIOR DE INGENIER{\'I}A INFORM{\'A}TICA}\\[1.5cm]
		{\large Proyecto Fin de Carrera Grado}\\[2cm]
		{\large \tfgdegreevar}\\[2cm]
		{\large \tfgtitlevar}\\[1.75cm]
		{\large Realizado por}\\
		{\large \tfgauthorvar}\\[1.75cm]
		{\large Dirigido por}\\
		{\large \tfgtutorvar}\\[1.5cm]
		{\large Departamento}\\
		{\large \tfgdepartmentvar}\\
		\vfill
		\begin{flushright}
			Sevilla, {\large \tfgdatevar}
		\end{flushright}
	\end{center}
\end{titlepage}
}
