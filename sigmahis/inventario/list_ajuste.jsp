<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
200069	VER LISTA DE ORDEN DE COMPRA NORMAL
200070	IMPRIMIR LISTA DE ORDEN DE COMPRA NORMAL
200071	AGREGAR SOLICITUD DE ORDEN DE COMPRA NORMAL
200072	MODIFICAR SOLICITUD DE ORDEN DE COMPRA NORMAL
==========================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

/*
if (
!( SecMgr.checkAccess(session.getId(),"0") 
	|| ((SecMgr.checkAccess(session.getId(),"200069") || SecMgr.checkAccess(session.getId(),"200070") || SecMgr.checkAccess(session.getId(),"200071") || SecMgr.checkAccess(session.getId(),"200072"))) )
	) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
*/


UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();


/*
INV250080		fg = DM = SOLICITUD DE DESCARTE DE MERCANCIA deja estado en tramite.
INV250020		fg = ED = AJUSTES POR ERROR O DESCARTE modifica recepcion material estado
INV250050		fg = AI = SOLICITUD DE AJUSTE A INVENTARIO deja estado en tramite.
INV250040		fg = ND = AJUSTES POR NOTA DE DEBITO Estado inicial tramite en el sp cambia a aprobado. 
INV250070		fg = NE = AJUSTES A NOTAS DE ENTREGA Estado tramite. 
*/

ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fgFilter = "";
String fg = request.getParameter("fg");
String wh = request.getParameter("wh");
String codRef = request.getParameter("cod_ref");


String fp = request.getParameter("fp");
String fDate = "";
String tDate = "";
if (codRef==null) codRef = "";

alWh = sbb.getBeanList(ConMgr.getConnection(), "select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen", CommonDataObject.class);
if (wh == null ) wh ="";
if(!wh.trim().equals(""))appendFilter = " and a.codigo_almacen="+wh;

if(fg==null) fg = "DM";
if(fp==null) fp = "";
/*
if(fg.equals("DM")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste in (2, 6, 7) ";
} else if(fg.equals("ED")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste = 1 ";
} else if(fg.equals("AI")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste = 4 ";
} else if(fg.equals("ND")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste in (3, 8) ";
} else if(fg.equals("NE")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste = 5 ";
}
*/
//fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste in (select codigo_ajuste from tbl_inv_tipo_ajustes where tipo_ajuste = '"+fg+"')";

//PARA USAR PROCESSO DE APROBACION DE AJUSTE POR QUE NO ESTABA REBAJNDO INVENTARIO CAUNDO TIPO DE AJUSTE ES ANULACION DE FACTURACION

if(fp.equals("aprob")){
fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste in (select codigo_ajuste from tbl_inv_tipo_ajustes where tipo_ajuste IN ('FAC','GEN'))";
}else{
fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste in (select codigo_ajuste from tbl_inv_tipo_ajustes where tipo_ajuste ='"+fg+"')";
}



if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
	
	String noAjuste = "";         // variables para mantener el valor de los campos filtrados en la consulta
	String anio     = "";

	if (request.getParameter("numero_ajuste") != null && !request.getParameter("numero_ajuste").trim().equals(""))
	{
		
		noAjuste   = request.getParameter("numero_ajuste");   // utilizada para mantener el número del ajuste	
		appendFilter += " and upper(a.numero_ajuste) like '%"+request.getParameter("numero_ajuste").toUpperCase()+"%'";
	} 
	if (request.getParameter("anio_ajuste") != null && !request.getParameter("anio_ajuste").trim().equals(""))
	 {
		appendFilter += " and upper(a.anio_ajuste) like '%"+request.getParameter("anio_ajuste").toUpperCase()+"%'";
		anio       = request.getParameter("anio_ajuste");   // utilizada para mantener el año del ajuste
	} 
	
	if (request.getParameter("ndebito") != null && !request.getParameter("ndebito").trim().equals(""))
	 {
		appendFilter += " and upper(a.n_d) like '%"+request.getParameter("ndebito").toUpperCase()+"%'";
	  } 
	
	 if (request.getParameter("estado") != null )
	 {
		appendFilter += " and upper(a.estado) like '%"+request.getParameter("estado").toUpperCase()+"%'";
	 }	
	
   if (request.getParameter("fDate") != null && !request.getParameter("fDate").trim().equals(""))
  {
    appendFilter += " and to_date(to_char(a.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+request.getParameter("fDate")+"','dd/mm/yyyy') ";
   
  }
  
   if (request.getParameter("tDate") != null && !request.getParameter("tDate").trim().equals(""))
  {
    appendFilter += " and to_date(to_char(a.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+request.getParameter("tDate")+"','dd/mm/yyyy') ";   
  }	
  
  if (!codRef.trim().equals("")){
    appendFilter += " and a.cod_ref = '"+codRef+"'"; 
  }
	if(!appendFilter.trim().equals(""))
	{
	sql = "select a.anio_ajuste, a.numero_ajuste, a.compania, a.codigo_ajuste, to_char(a.fecha_ajuste, 'dd/mm/yyyy') fecha_ajuste, b.descripcion, al.descripcion descAlmacen, a.numero_doc as documento, a.n_d as nd, a.total as total, a.estado, decode(a.estado, 'A', 'APROBADO', 'T', 'TRAMITE', 'P', 'PENDIENTE', 'R', 'RECHAZADO') estado_desc, decode(instr(a.observacion, 'PDT'), 0, '', substr(a.observacion, instr(a.observacion, 'PDT'), length(a.observacion))) pdt, a.cod_ref from tbl_inv_ajustes a, tbl_inv_tipo_ajustes b, tbl_inv_almacen al " + fgFilter +" and a.codigo_ajuste = b.codigo_ajuste and a.compania = "+(String) session.getAttribute("_companyId")+" and a.codigo_almacen = al.codigo_almacen and al.compania = a.compania "+ appendFilter + " order by a.fecha_ajuste desc";
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
	}

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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
document.title = 'Inventario - '+document.title;

function add(){
	abrir_ventana('../inventario/reg_ajuste.jsp?mode=add&fg=<%=fg%>');
}

function edit(anio,numero, codigo){
var codigo= codigo;
//alert(codigo);
if(codigo==1) {
abrir_ventana('../inventario/reg_ajuste.jsp?mode=view&numero='+numero+'&codigo='+codigo+'&anio='+anio+'&fg=FAC');
}else{
abrir_ventana('../inventario/reg_ajuste.jsp?mode=view&numero='+numero+'&codigo='+codigo+'&anio='+anio+'&fg=<%=fg%>');
}
}

function aprobar(anio,numero, codigo){
var codigo= codigo;
//alert(codigo);
if(codigo==1) {
abrir_ventana('../inventario/reg_ajuste.jsp?mode=edit&numero='+numero+'&codigo='+codigo+'&anio='+anio+'&fg=FAC&fp=<%=fp%>');
}else {
abrir_ventana('../inventario/reg_ajuste.jsp?mode=edit&numero='+numero+'&codigo='+codigo+'&anio='+anio+'&fg=<%=fg%>&fp=<%=fp%>'); 

}

}

function printList(){
	<% if ((appendFilter != null && !appendFilter.trim().equals("")) && al.size() != 0){%>
	abrir_ventana('../inventario/print_list_ajuste.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&fg=<%=fg%>');
	<%}else{%>
	alert('I N T R O D U Z C A     P A R Á M E T R O S    D E    B Ú S Q U E D A');
	<%}%>
	
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.equals("FAC")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - SOLICITUD DE AJUSTE POR FACTURA"></jsp:param>
</jsp:include>
<%} else if(fg.equals("GEN")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - AJUSTES GENERAL"></jsp:param>
</jsp:include>
<%} else if(fg.equals("NE")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVENTARIO - AJUSTES A NOTAS DE ENTREGA"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
   		 <td  colspan="4" align="right">
<%
if (!fp.equals("aprob")){
%>
			<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Ajuste ]</a></authtype>
<%
}
%>
		</td>
  </tr>
  
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<tr class="TextFilter">
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				 <td width="50%" >
     			 Almac&eacute;n
     				 <%=fb.select("wh",alWh,wh,"T")%>
   				</td>
		
			  	<td width="50%">
          			Fecha
          			<jsp:include page="../common/calendar.jsp" flush="true">
          			<jsp:param name="noOfDateTBox" value="2" />
          			<jsp:param name="nameOfTBox1" value="fDate" />
          			<jsp:param name="valueOfTBox1" value="" />
          			<jsp:param name="nameOfTBox2" value="tDate" />
          			<jsp:param name="valueOfTBox2" value="" />
          			<jsp:param name="fieldClass" value="Text10" />
          			<jsp:param name="buttonClass" value="Text10" />
          			</jsp:include>
                </td>
		</tr>
		
		<tr class="TextFilter">
				<td >
					A&ntilde;o
					<%=fb.intBox("anio_ajuste","",false,false,false,10)%>
					<%//=fb.submit("go","Ir")%>

								
					Ajuste No.
					<%=fb.intBox("numero_ajuste","",false,false,false,10)%>
					<%//=fb.submit("go","Ir")%>
					Nota/Debito
					<%=fb.intBox("ndebito","",false,false,false,10)%>
					
				</td>
			
				<td >
				 	Estado
					<%//=fb.select("estado","A=Aprobado,T=Tramite","T")%>
					<%=fb.select("estado","A=APROBADO,T=TRAMITE,R=RECHAZADO","",false,false,0,"",null,null,"","T")%>
                    &nbsp;&nbsp;
                    <cellbytelabel>C&oacute;d. Ref.</cellbytelabel>
                    <%=fb.textBox("cod_ref",codRef,false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
		</tr>
        
        <%=fb.formEnd()%>
		
			
	</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  	<tr>
    	<td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200070")){
%>
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
<%
//}
%>
			&nbsp;
		</td>
  	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
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
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
				<%=fb.hidden("anio_ajuste",request.getParameter("anio_ajuste"))%>
				<%=fb.hidden("fDate",request.getParameter("fDate"))%>
				<%=fb.hidden("numero_ajuste",request.getParameter("numero_ajuste"))%>
				<%=fb.hidden("tDate",request.getParameter("tDate"))%>
				<%=fb.hidden("estado",request.getParameter("estado"))%>
				<%=fb.hidden("ndebito",request.getParameter("ndebito"))%>
                <%=fb.hidden("cod_ref",codRef)%>
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
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
				<%=fb.hidden("anio_ajuste",request.getParameter("anio_ajuste"))%>
				<%=fb.hidden("fDate",request.getParameter("fDate"))%>
				<%=fb.hidden("numero_ajuste",request.getParameter("numero_ajuste"))%>
				<%=fb.hidden("tDate",request.getParameter("tDate"))%>
				<%=fb.hidden("estado",request.getParameter("estado"))%>
				<%=fb.hidden("ndebito",request.getParameter("ndebito"))%>
                <%=fb.hidden("cod_ref",codRef)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="4%">A&ntilde;o</td>
			<td width="5%">No. Ajuste</td>
			<td width="5%">Cod. Ajuste</td>
			<td width="5%">C&oacute;d. Ref.</td>
			<td width="5%">N/D</td>
			<td width="6%">Fecha Doc.</td>
			<td width="25%" align="left">Tipo Ajuste</td>
			<td width="20%" align="left">Almacen</td>
			<td width="7%" align="center">No.Doc</td>
			<td width="5%" align="left">Estado</td>
			<td width="12%" align="left">&nbsp;</td>
			
			<td width="3%">&nbsp;</td>
		</tr>
		  	<% if ((appendFilter == null || appendFilter.trim().equals("")) && al.size() == 0){%>
		<tr class="TextRow01" align="center">
			<td colspan="12">&nbsp; </td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="12"> <font color="#FF0000"> I N T R O D U Z C A &nbsp;&nbsp;&nbsp;&nbsp;P A R Á M E T R O S&nbsp;&nbsp;&nbsp;&nbsp;D E&nbsp;&nbsp;&nbsp;&nbsp;B Ú S Q U E D A &nbsp;&nbsp; ó  &nbsp;&nbsp;[I R] &nbsp;&nbsp;   P A R A  &nbsp;&nbsp;   V E R &nbsp;&nbsp;   T O D O S</font></td>
		</tr>
		<%}%>
		
		
		
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("anio_ajuste")%></td>
			<td align="center"><%=cdo.getColValue("numero_ajuste")%></td>
			<td align="center"><%=cdo.getColValue("codigo_ajuste")%></td>
			<td align="center"><%=cdo.getColValue("cod_ref","")%></td>
			<td align="center"><%=cdo.getColValue("nd")%></td>
			<td align="center"><%=cdo.getColValue("fecha_ajuste")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td align="left"><%=cdo.getColValue("descAlmacen")%></td>
			<td align="center"><%=cdo.getColValue("documento")%></td>
			<td align="left"><%=cdo.getColValue("estado_desc")%></td>
			<td align="left"><%=cdo.getColValue("pdt")%></td>
			<td align="center">
<%
if (fp.equalsIgnoreCase("aprob") && cdo.getColValue("estado").trim().equalsIgnoreCase("T")){
%>
		<authtype type='6'><a href="javascript:aprobar(<%=cdo.getColValue("anio_ajuste")%>,<%=cdo.getColValue("numero_ajuste")%>,'<%=cdo.getColValue("codigo_ajuste")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Aprobar</a></authtype>
<%
} else {
%>
	<authtype type='1'><a href="javascript:edit(<%=cdo.getColValue("anio_ajuste")%>,<%=cdo.getColValue("numero_ajuste")%>,'<%=cdo.getColValue("codigo_ajuste")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype>
<%
}
%>

			</td>
		</tr>
<%
}
%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
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
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
				<%=fb.hidden("anio_ajuste",request.getParameter("anio_ajuste"))%>
				<%=fb.hidden("fDate",request.getParameter("fDate"))%>
				<%=fb.hidden("numero_ajuste",request.getParameter("numero_ajuste"))%>
				<%=fb.hidden("tDate",request.getParameter("tDate"))%>
				<%=fb.hidden("estado",request.getParameter("estado"))%>
				<%=fb.hidden("ndebito",request.getParameter("ndebito"))%>
                <%=fb.hidden("cod_ref",codRef)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
				<%=fb.hidden("anio_ajuste",request.getParameter("anio_ajuste"))%>
				<%=fb.hidden("fDate",request.getParameter("fDate"))%>
				<%=fb.hidden("numero_ajuste",request.getParameter("numero_ajuste"))%>
				<%=fb.hidden("tDate",request.getParameter("tDate"))%>
				<%=fb.hidden("estado",request.getParameter("estado"))%>
				<%=fb.hidden("ndebito",request.getParameter("ndebito"))%>
                <%=fb.hidden("cod_ref",codRef)%>
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
