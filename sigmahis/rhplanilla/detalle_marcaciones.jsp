<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);


SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String accept = request.getParameter("accept");
String key = "";
String size = request.getParameter("size");
String sql = "";
String appendFilter = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String anio = request.getParameter("anio");
String planilla = request.getParameter("planilla");
String periodo = request.getParameter("periodo");
String seccion = request.getParameter("seccion");

String empId = request.getParameter("empid");
String trxId = request.getParameter("trx");
String tipoId = request.getParameter("tipo");

String fecha="",fechaIngreso="";
int benLastLineNo = 0, prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anioC = CmnMgr.getCurrentDate("yyyy");
String mes = CmnMgr.getCurrentDate("mm");
String dia = CmnMgr.getCurrentDate("dd");
int per = 0;
double total = 0.00;
int iconHeight = 48;
int iconWidth = 48;
int extraLastLineNo = 0;




int day = Integer.parseInt(CmnMgr.getCurrentDate("dd"));
int mont = Integer.parseInt(CmnMgr.getCurrentDate("mm"));

if(day >16) per = mont*2;
else per =  mont*2-1;

	if (anio == null) anio = anioC;	
	if (periodo == null) periodo = ""+per;
	if (planilla == null) planilla = "1";
	
		
if (tab == null) tab = "0";
if (mode == null) mode = "add";
if(request.getParameter("extraLastLineNo")!=null && ! request.getParameter("extraLastLineNo").equals(""))
extraLastLineNo=Integer.parseInt(request.getParameter("extraLastLineNo"));
else extraLastLineNo=0;


if (request.getMethod().equalsIgnoreCase("GET"))
{
 		if (anio == null) throw new Exception("El Año no es válido. Por favor intente nuevamente!");
		if (periodo == null) throw new Exception("El Periodo no es válido. Por favor intente nuevamente!");
	  if (planilla == null) throw new Exception("El Código de Planilla no es válido. Por favor intente nuevamente!");
	  
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
 
     if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
	}
 
	  
 	sql = "select e.num_empleado as numero, e.primer_nombre||' '||decode(e.sexo, 'F', decode(e.apellido_casada, null,e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) nombre, e.emp_id as empId, e.provincia, e.sigla, e.tomo, e.asiento, u.descripcion, u.codigo, to_char(s.regular,'999,990.00') as regular, to_char(s.domingo,'999,990.00') as domingo, to_char(s.nacional,'999,990.00') as nacional, to_char(s.libre_trabajado,'999,990.00') as libre, to_char(s.extra_125,'999,990.00') as e125, to_char(s.extra_150,'999,990.00') as e150, to_char(s.extra_175,'999,990.00') as e175, to_char(s.extra_188,'999,990.00') as e188, to_char(s.extra_219,'999,990.00') as e219, to_char(s.extra_225,'999,990.00') as e225,to_char(s.extra_250,'999,990.00') as e250, to_char(s.extra_263,'999,990.00') as e263, to_char(s.extra_306,'999,990.00') as e306, to_char(s.extra_313,'999,990.00') as e313, to_char(s.extra_329,'999,990.00') as e329, to_char(s.extra_375,'999,990.00') as e375, to_char(s.extra_394,'999,990.00') as e394, to_char(s.extra_438,'999,990.00') as e438, to_char(s.extra_459,'999,990.00') as e459, to_char(s.extra_547,'999,990.00') as e547, to_char(s.extra_656,'999,990.00') as e656, to_char(s.extra_766,'999,990.00') as e766, to_char(s.calamidad,'999,990.00') as calam, to_char(s.congreso,'999,990.00') as cong, to_char(s.duelo,'999,990.00') as duelo, to_char(s.seminario,'999,990.00') as semi, to_char(s.nacimiento,'999,990.00') as naci, to_char(s.matrimonio,'999,990.00') as matri, to_char(s.permisos,'999,990.00') as perm, to_char(s.incapacidad,'999,990.00') as inc, to_char(s.ausencia_injustificada,'999,990.00') as ausc, to_char(s.tardanzas,'999,990.00') as tard, to_char(s.descanso_prolongado,'999,990.00') as desp, to_char(s.salida_temprana,'999,990.00') as sal, to_char(s.vacacion,'999,990.00') as vac, to_char(s.gravidez,'999,990.00') as grav, to_char(s.enero1,'999,990.00') as ene1, to_char(s.mayo1,'999,990.00') as mayo1, to_char(s.noviembre10,'999,990.00') as nov10, to_char(s.diciembre25,'999,990.00') as dic25, to_char(s.noviembre28,'999,990.00') as nov28, to_char(s.noviembre3,'999,990.00') as nov3, to_char(s.noviembre5,'999,990.00') as nov5, to_char(s.diciembre8,'999,990.00') as dic8, to_char(s.enero9,'999,990.00') as ene9, to_char(s.compensatorio,'999,990.00') as comp, to_char(s.constancia_medica_nopaga,'999,990.00') as cmnp, to_char(s.constancia_medica,'999,990.00') as cons, to_char(s.martes_carnaval,'999,990.00') as mart, to_char(s.viernes_santo,'999,990.00') as vier from tbl_pla_empleado e, tbl_pla_cronox_temporal s, tbl_sec_unidad_ejec u where  e.compania="+(String) session.getAttribute("_companyId")+ appendFilter +" and s.emp_id = e.emp_id and e.compania = s.compania and e.ubic_fisica = u.codigo and e.compania = u.compania and s.periodo= "+periodo+" order by u.codigo, e.num_empleado";
//	al=SQLMgr.getDataList(sql);
	
al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	
	rowCount = CmnMgr.getCount("select count(*) count from tbl_pla_empleado e, tbl_pla_cronox_temporal s, tbl_sec_unidad_ejec u where e.compania="+(String) session.getAttribute("_companyId")+ appendFilter +" and s.emp_id = e.emp_id and e.compania = s.compania and e.ubic_fisica = u.codigo and s.periodo= "+periodo+" and e.compania = u.compania");
	
extraLastLineNo=al.size();

System.out.println("Geetesh################################printing al size="+al.size());

	
  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);
  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;
  if(rowCount==0) pVal=0;
  else pVal=preVal;
	
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;


function setBAction(fName,actionValue)
{
//alert('test');
	document.form0.submit();
}

function actualiza()
{

abrir_ventana('../rhplanilla/actualiza_ajuste_trx.jsp?mode=view');
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr class="TextRow02">
  <td>&nbsp;</td>
</tr>
<tr class="TextRow02">
  <td>&nbsp;
  <table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>	
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>			
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
  
  </td>
</tr>

<tr>
  <td>
    <table width="100%" cellpadding="1" cellspacing="0">

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("baction","")%> 



    <tr class="TextHeader">
      <td colspan="11" align="center">
        Proceso para Cargar las Marcaciones para Cálculo de Planilla 
		<br> Año : &nbsp;<%=fb.textBox("anio",anio,false,false,false,5)%>
        <%=fb.select(ConMgr.getConnection(),"select cod_planilla , nombre from tbl_pla_planilla where compania = "+(String) session.getAttribute("_companyId")+" order by cod_planilla" ,"planilla",planilla,false,false,0,"Text10",null,null)%> &nbsp;&nbsp;&nbsp;
		Periodo : &nbsp;<%=fb.textBox("periodo",periodo,false,false,false,5)%>
		
		<%
		System.out.println("###############################################Printing After Planilla Type");
		%>
			 
		</td>
    </tr>
<%//=fb.formEnd(true)%>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ===========   R E S U L T S   S T A R T   H E R E   ============== -->

		<table align="center" width="99%" cellpadding="0" cellspacing="1">
		
	
		<tbody id="list">
	
		<%//=fb.hidden("baction","")%> 
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("periodo",periodo)%>
				
		
		<%=fb.hidden("tab","0")%>
				<tr class="TextHeader">
				<%
		System.out.println("###############################################Printing After Planilla Type---1");
		%>
			<td width="4%"># Emp.</td>
			<td width="20%" align="left">Descripci&oacute;n</td>
			<td width="3%" align="center">Reg.</td>
			<td width="3%" align="center">Dom.</td>
			<td width="3%" align="center">Nac.</td>
			<td width="3%" align="center">LibT</td>
			<td width="3%" align="center">E125</td>
			<td width="3%" align="center">E150</td>
			<td width="3%" align="center">E175</td>
			<td width="3%" align="center">E188</td>
			<td width="3%" align="center">E219</td>
			<td width="3%" align="center">E225</td>
			<td width="3%" align="center">E250</td>
			<td width="3%" align="center">E263</td>
			<td width="3%" align="center">E306</td>
			<td width="3%" align="center">E313</td>
			
			<td width="3%" align="center">E329</td>
			<td width="3%" align="center">E375</td>
			<td width="3%" align="center">E394</td>
			<td width="3%" align="center">E438</td>
			<td width="3%" align="center">E459</td>
			<td width="3%" align="center">E547</td>
			<td width="3%" align="center">E656</td>
			<td width="3%" align="center">E766</td>
			<td width="3%" align="center">Calam</td>
			<td width="3%" align="center">Cong</td>
			
			<td width="3%" align="center">Duel</td>
			<td width="3%" align="center">Semi</td>
			<td width="3%" align="center">Nac.</td>
			<td width="3%" align="center">Matr</td>
			<td width="3%" align="center">Perm</td>
			<td width="3%" align="center">Inc.</td>
			<td width="3%" align="center">Aus</td>
			<td width="3%" align="center">Tard</td>
			<td width="3%" align="center">DesP</td>
			<td width="3%" align="center">SalT</td>
			
			<td width="3%" align="center">Vac</td>
			<td width="3%" align="center">Grav</td>
			<td width="3%" align="center">Ene1</td>
			<td width="3%" align="center">May1</td>
			<td width="3%" align="center">Nov10</td>
			<td width="3%" align="center">Dic25</td>
			<td width="3%" align="center">Nov28</td>
			<td width="3%" align="center">Nov3</td>
			<td width="3%" align="center">Nov5</td>
			<td width="3%" align="center">Dic8</td>
			
			<td width="3%" align="center">Ene9</td>
			<td width="3%" align="center">Comp</td>
			<td width="3%" align="center">Cmnp</td>
			<td width="3%" align="center">ConM</td>
			<td width="3%" align="center">MCar</td>
			<td width="3%" align="center">VSan</td>
		</tr>
		
			<%
		System.out.println("###############################################Printing After Planilla Type---2");
		%>
<%
String nombrePla = "";
String color="";
for (int i=0; i<al.size(); i++)
{
	key=al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
		if (!nombrePla.equalsIgnoreCase(cdo.getColValue("codigo")))
				 {
				%>
				  
					 <tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
                      <td colspan="8" class="TitulosdeTablas"> [<%=cdo.getColValue("codigo")%>] - [<%=cdo.getColValue("descripcion")%>]</td>
                   </tr>
				<% 
				  }
				 %>
			
		<%
		System.out.println("###############################################Printing After Planilla Type----3------------"+i);
	
		%>
					<%=fb.hidden("key"+i,key)%>
					<%=fb.hidden("tab","0")%>
					
						<%=fb.hidden("emp_id"+i,cdo.getColValue("empId"))%>
						<%=fb.hidden("numEmp"+i,cdo.getColValue("numero"))%>
						<%=fb.hidden("anio"+i,anio)%>
						<%=fb.hidden("periodo"+i,periodo)%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<%
		System.out.println("###############################################Printing Empcode----"+cdo.getColValue("empId"));
		%>
			<td align="left"><%=cdo.getColValue("numero")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("regular")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("domingo")+i)%></td>		
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("nacional")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("libre")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e125")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e150")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e175")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e188")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e219")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e225")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e250")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e263")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e306")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e313")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e329")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e375")+i)%></td>	
			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e394")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e438")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e459")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e547")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e656")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("e766")+i)%></td>	
			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("calam")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("cong")+i)%></td>
						
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("duelo")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("semi")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("naci")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("matri")+i)%></td>	
			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("perm")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("inc")+i)%></td>
						
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("ausc")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("tard")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("desp")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("sal")+i)%></td>		
			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("vac")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("grav")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("ene1")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("mayo1")+i)%></td>	
			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("nov10")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("dic25")+i)%></td>
						
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("nov28")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("nov3")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("nov5")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("dic8")+i)%></td>	
			
			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("ene9")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("comp")+i)%></td>
						
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("cmnp")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("cons")+i)%></td>			
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("mart")+i)%></td>
			<td><%=CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("vier")+i)%></td>					
			
		
			
		</tr>
<%
	nombrePla = cdo.getColValue("codigo");
	cdo=null;
}
%>
	<%
		System.out.println("###############################################Printing After Planilla Type---4");
		%>
 </tbody>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>


		    <tr class="TextRow02">
		 	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Acceptar')return true;");%>
            <td align="right">
			<%
			  System.out.println("###############################################Geetesh Printing al Size before submit "+request.getParameter("size"));
			  %>
			  
           <%=fb.hidden("size",""+al.size())%>
            <%//=fb.radio("saveOption","O",true,false,false)%><!--Mantener Abierto-->
            <%//=fb.radio("saveOption","C",false,false,false)%><!--Cerrar-->
			<%=fb.submit("save","Acceptar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
           </tr>
		
		
	
		
	<%=fb.formEnd(true)%>
	</table>
  </td>
</tr>

</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">

<tr class="TextRow02">
  <td>&nbsp;
  <table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">

<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>	
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>							
				<td width="9%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
			  <td width="26%">Total Registro(s) <%=rowCount%></td>
			  <td width="55%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
			  <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
				
				
	
				
				
				
			</tr>
		</table>
	</td>
</tr>
</table>

<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
} //GET

else { 
System.out.println("###############################################Geetesh Printing Inside Post");

String saveOption =request.getParameter("saveOption");
 String baction = request.getParameter("baction");
%> 
<html>
<head>
<%@ include file="../common/header_param.jsp"%>



<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">

function closeWindow()
{

	if(confirm('Se generarán las Transacciones Para Planilla.... Desea Continuar'))
 	{
		if(executeDB('<%=request.getContextPath()%>','call sp_pla_crea_trx_cronox(<%=anio%>,<%=periodo%>,<%=(String)session.getAttribute("_companyId")%>,\'<%=(String) session.getAttribute("_userName")%>\')',''))
			{
				alert('Se crearon las Transacciones!');	
									
		abrir_ventana('../rhplanilla/carga_marcaciones.jsp?mode=view&planilla=<%=planilla%>&anio=<%=anio%>&periodo=<%=periodo%>&tab=0');
		
			 } else  alert('No se han creado las transacciones...Consulte al Administrador!');
			 
	}
	window.close();
	}
	
	function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?anio=<%=anio%>&periodo=<%=periodo%>';
}
</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
