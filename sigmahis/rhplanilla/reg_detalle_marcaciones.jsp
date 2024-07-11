<%//@ page errorPage="../error.jsp"%>
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
	
	String pivotSql="select distinct nombre, factor_multi from tbl_pla_t_horas_ext where nombre is not null order by 1";
	StringBuffer sbPivot = new StringBuffer();
	ArrayList alPivot = new ArrayList();
	alPivot=SQLMgr.getDataList(pivotSql);
	for(int ip=0;ip<alPivot.size();ip++){
		CommonDataObject cdo = (CommonDataObject) alPivot.get(ip);
		if(ip>0) sbPivot.append(","); 
		sbPivot.append("'");
		sbPivot.append(cdo.getColValue("factor_multi"));
		sbPivot.append("' as ");
		sbPivot.append(cdo.getColValue("nombre"));
	}

	StringBuffer sbSql = new StringBuffer();
    sbSql.append("select * from ( select d.ue_codigo, g.descripcion, e.emp_id,e.nombre_empleado as nombre, e.num_empleado numero, e.provincia, e.sigla, e.tomo, e.asiento, f.factor_multi as factor, round(d.cantidad * f.factor_multi * e.rata_hora, 2) total  from tbl_pla_st_det_disttur d , vw_pla_empleado e , tbl_pla_t_horas_ext f, tbl_pla_ct_grupo g where d.emp_id = e.emp_id and e.estado = 1 and d.compania = e.compania and d.tipo_he = f.codigo and e.compania = g.compania and d.ue_codigo = g.codigo and e.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	sbSql.append(" and  d.anio_pago=");
	sbSql.append(anioC);
	sbSql.append("   and d.periodo_pago = 15  order by 1 asc ) pivot(sum(total) for factor in (");
	sbSql.append(sbPivot);
	sbSql.append(") ) order by 1,2");
	  
 
//	al=SQLMgr.getDataList(sql);
	
al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	
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
         Marcaciones Generadas para Cálculo de Planilla 
		<br> Año : &nbsp;<%=fb.textBox("anio",anioC,false,false,false,5)%>
        <%=fb.select(ConMgr.getConnection(),"select cod_planilla , nombre from tbl_pla_planilla where compania = "+(String) session.getAttribute("_companyId")+" order by cod_planilla" ,"planilla",planilla,false,false,0,"Text10",null,null)%> &nbsp;&nbsp;&nbsp;
		Periodo : &nbsp;<%=fb.textBox("periodo",periodo,false,false,false,5)%>
		
		<%
		System.out.println("#####Printing After Planilla Type");
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
		System.out.println("######Printing After Planilla Type---1");
		%>
			<td width="4%"># Emp.</td>
			<td width="20%" align="left">Descripci&oacute;n</td>
			<td width="3%" align="center">Reg.</td>
			<td width="3%" align="center">Dom.</td>
			<td width="3%" align="center">Nac.</td>
			<td width="3%" align="center">LibT</td>
<%
for (int ip=0; ip<alPivot.size(); ip++) {
	CommonDataObject cdo = (CommonDataObject) alPivot.get(ip);
%>
			<td width="3%" align="center"><%=cdo.getColValue("nombre")%></th>
<% } %>
		</tr>
		
			<%
		System.out.println("########Printing After Planilla Type---2");
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
	
		if (!nombrePla.equalsIgnoreCase(cdo.getColValue("ue_codigo")))
				 {
				%>
				  
					 <tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
                      <td colspan="8" class="TitulosdeTablas"> [<%=cdo.getColValue("ue_codigo")%>] - [<%=cdo.getColValue("descripcion")%>]</td>
                   </tr>
				<% 
				  }
				 %>
			
		<%
		System.out.println("#######Printing After Planilla Type----3-----"+i);
	
		%>
			<%=fb.hidden("key"+i,key)%>
			<%=fb.hidden("tab","0")%>
			<%=fb.hidden("emp_id"+i,cdo.getColValue("empId"))%>
			<%=fb.hidden("numEmp"+i,cdo.getColValue("numero"))%>
			<%=fb.hidden("anio"+i,anio)%>
			<%=fb.hidden("periodo"+i,periodo)%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<%
		System.out.println("#######Printing Empcode----"+cdo.getColValue("empId"));
		%>
			<td align="left"><%=cdo.getColValue("numero")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td>&nbsp;&nbsp;</td>
			<td>&nbsp;&nbsp;</td>		
			<td>&nbsp;&nbsp;</td>
			<td>&nbsp;&nbsp;</td>			
<%
for (int ip=0; ip<alPivot.size(); ip++) {
	CommonDataObject cdoPivot = (CommonDataObject) alPivot.get(ip);
%>
	<td><%=cdo.getColValue(cdoPivot.getColValue("nombre"),"&nbsp;")%></td>
<% } %>
		</tr>
<%
	nombrePla = cdo.getColValue("ue_codigo");
	cdo=null;
}
%>
	<%
		System.out.println("########Printing After Planilla Type---4");
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
			  System.out.println("##########Geetesh Printing al Size before submit "+request.getParameter("size"));
			  %>
			  
           <%=fb.hidden("size",""+al.size())%>
            <%//=fb.radio("saveOption","O",true,false,false)%><!--Mantener Abierto-->
            <%//=fb.radio("saveOption","C",false,false,false)%><!--Cerrar-->
			<%=fb.submit("save","Acceptar",true,true,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
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
System.out.println("#######Geetesh Printing Inside Post");

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
