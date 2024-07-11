<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String namePlanilla = "";
String cod_planilla = "";
String cuenta = "",und="";
int iconHeight = 48;
int iconWidth = 48;
if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if (request.getParameter("cuenta") != null && !request.getParameter("cuenta").trim().equals(""))
  {
    appendFilter += " and upper(a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6) like '%"+request.getParameter("cuenta").toUpperCase()+"%'";
    cuenta = request.getParameter("cuenta");	
  }
  if (request.getParameter("namePlanilla") != null && !request.getParameter("namePlanilla").trim().equals(""))
  {
    appendFilter += " and upper(d.nombre) like '%"+request.getParameter("namePlanilla").toUpperCase()+"%'";
    namePlanilla = request.getParameter("namePlanilla");	
  }
  if(request.getParameter("cod_planilla")!=null && !request.getParameter("cod_planilla").trim().equals(""))
  {
  	appendFilter += " and upper(a.cod_planilla) like '%"+request.getParameter("cod_planilla").toUpperCase()+"%'";
    cod_planilla = request.getParameter("cod_planilla");	
  }
  if(request.getParameter("und")!=null && !request.getParameter("und").trim().equals(""))
  {
  	appendFilter += " and a.unidad_adm = "+request.getParameter("und").toUpperCase();
    und = request.getParameter("und");	
  }
  
	sql="select distinct a.cod_planilla, decode(a.tipo,'A','',a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6) as cuenta, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.cod_concepto, a.unidad_adm, b.descripcion as cosd, decode(a.tipo,'A','',a.cod_concepto||' - '||c.descripcion) as nameConcepto, d.nombre as namePlanilla,decode(a.tipo,'A','DETALLADO','G','GENERAL') as tipo,a.tipo cod_tipo,decode(a.tipo,'A',(select codigo||' - '||descripcion from tbl_sec_unidad_ejec where codigo=a.unidad_adm and compania=a.cod_compania ),'G',' ') as descripcion,a.id from tbl_pla_cuenta_planilla a, tbl_con_catalogo_gral b, tbl_pla_cuenta_concepto c, tbl_pla_planilla d where a.cta1=b.cta1(+) and a.cta2=b.cta2(+) and a.cta3=b.cta3(+) and a.cta4=b.cta4(+) and a.cta5=b.cta5(+) and a.cta6=b.cta6(+) and a.cod_compania=b.compania(+) and a.cod_concepto=c.cod_concepto(+)  and a.cod_compania=c.cod_compania(+) and  a.cod_planilla = d.cod_planilla(+) and a.cod_compania=d.compania(+) and a.cod_compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.cod_planilla ,a.tipo desc,a.unidad_adm ";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
	
if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Facturacion - '+document.title;
var gTitleAlert = '<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>';
function setIndex(k){document.form0.index.value=k;checkOne('form0','check',<%=al.size()%>,eval('document.form0.check'+k),0);}
function mouseOut(obj,option){var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Registrar Nueva Cuenta';break;
		case 1:msg='Editar Cuenta';break;
		case 2:msg='Ver Cuenta';break;


	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function goOption(option)
{
	if(option==0)add();
	else
	{
	 if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	 else
	 {
		var k=document.form0.index.value;
		if(k=='')CBMSG.warning('Por favor seleccione un registro antes de ejecutar una acción!');
		else
		{
			var id = eval('document.form0.id'+k).value ; 
			
		    if(option==1)edit(id,'edit');
		    else if(option==2)edit(id,'view');
		}
	  }
	}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function add(){abrir_ventana('../rhplanilla/ctacontable_x_planilla_config.jsp?mode=add');}
function edit(id,mode){abrir_ventana('../rhplanilla/ctacontable_x_planilla_config.jsp?mode='+mode+'&id='+id);}
function printList(){abrir_ventana('../rhplanilla/print_list_cta_x_planilla.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}

     </script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
 <jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="PLANILLA - CUENTAS POR PLANILLA"></jsp:param>
</jsp:include> 

<table align="center" width="99%" cellpadding="1" cellspacing="0"  id="_tblMain">
	<tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='3'><a href="javascript:goOption(0)" class="hint hint--left" data-hint="Registra Nueva Cuenta"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/case.jpg"></a></authtype>
		<authtype type='4'><a href="javascript:goOption(1)" class="hint hint--left" data-hint="Editar Cuenta"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/edit.png"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(2)" class="hint hint--left" data-hint="Ver Cuenta"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,14)" onMouseOut="javascript:mouseOut(this,14)"  src="../images/search.gif"></a></authtype>	
		
		</td>
	</tr>

	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ 
-->
			<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
			 
			<tr class="TextFilter">
			<td width="35%">&nbsp;Nombre de Planilla
						<%=fb.textBox("namePlanilla",namePlanilla,false,false,false,25,null,null,null)%>
			</td>
			<td width="32%">&nbsp;C&oacute;d. Planilla.
						<%=fb.textBox("cod_planilla",cod_planilla,false,false,false,10,null,null,null)%> &nbsp;Codigo De Unidad:
						<%=fb.intBox("und",und,false,false,false,10,null,null,null)%>
			</td>
			<td width="33%">&nbsp;Cuenta
						<%=fb.textBox("cuenta",cuenta,false,false,false,30,null,null,null)%>
						<%=fb.submit("go","Ir")%></td>
		</tr>
 
<%=fb.formEnd(true)%>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></td>
	</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%> 
<%=fb.hidden("cod_planilla",cod_planilla)%>
<%=fb.hidden("namePlanilla",namePlanilla)%>
<%=fb.hidden("cuenta",cuenta)%>
<%=fb.hidden("und",und)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("cod_planilla",cod_planilla)%>
<%=fb.hidden("namePlanilla",namePlanilla)%>
<%=fb.hidden("cuenta",cuenta)%>
<%=fb.hidden("und",und)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
  <tr class="TextHeader" align="center"> 
    <td width="12%">&nbsp;Tipo Asiento</td>
    <td width="32%">&nbsp;Unidad</td>
	<td width="22%">&nbsp;Cuenta</td>
	<td width="29%">&nbsp;Concepto</td>
    <td width="5%">&nbsp;</td>
  </tr>
  <%
		 String name = "";
		 for (int i=0; i<al.size(); i++)
		 {
		 CommonDataObject cdo = (CommonDataObject) al.get(i);
		 String color = "TextRow02";
		 if (i % 2 == 0) color = "TextRow01";
			 
		 if (!name.equalsIgnoreCase(cdo.getColValue("namePlanilla")))
		 {
		 %>
  <tr align="left" bgcolor="#FFFFFF" class="TextHeader">
    <td colspan="5" class="TitulosdeTablas"> [<%=cdo.getColValue("cod_planilla")%>] - <%=cdo.getColValue("namePlanilla")%></td>
  </tr>
  <%}%>
		  
  <%=fb.hidden("id"+i, cdo.getColValue("id"))%>  
  <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"> 
    <td>&nbsp;<%=cdo.getColValue("tipo")%></td>
    	
	<%if(cdo.getColValue("cod_tipo").trim().equals("G")){%><td colspan="2" align="right">&nbsp;<%=cdo.getColValue("cuenta")%>&nbsp;-&nbsp;<%=cdo.getColValue("cosd")%></td>
	<%}else{%>
	<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
	<td>&nbsp;<%=cdo.getColValue("cuenta")%></td>
	<%}%>
	
	
	<td>&nbsp;<%=cdo.getColValue("nameConcepto")%></td>	
	<td align="center">&nbsp;<%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
  </tr>
  <%
	        name = cdo.getColValue("namePlanilla");
            }
            %>

 
<%=fb.formEnd()%>
		</table>
</div>
</div>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("cod_planilla",cod_planilla)%>
<%=fb.hidden("namePlanilla",namePlanilla)%>
<%=fb.hidden("cuenta",cuenta)%>
<%=fb.hidden("und",und)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("cod_planilla",cod_planilla)%>
<%=fb.hidden("namePlanilla",namePlanilla)%>
<%=fb.hidden("cuenta",cuenta)%>
<%=fb.hidden("und",und)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr> 
</table>
</body>
</html>
<%
}
%>
