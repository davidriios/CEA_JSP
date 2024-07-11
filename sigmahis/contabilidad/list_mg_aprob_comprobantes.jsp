<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.contabilidad.Comprobante"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="CompMgr" scope="page" class="issi.contabilidad.ComprobanteMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CompMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String consecutivo = request.getParameter("consecutivo");
String anio        = request.getParameter("ea_ano");
String clase       = request.getParameter("clase_comprob");
String mes       ="";

String fgFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(fg==null) fg = "";
if(fp==null) fp = "";
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

	if (request.getParameter("ea_ano") != null && !request.getParameter("ea_ano").trim().equals(""))
	{
		appendFilter += " and a.ea_ano = "+request.getParameter("ea_ano");
    	anio = request.getParameter("ea_ano");
	} 
	if (request.getParameter("consecutivo") != null && !request.getParameter("consecutivo").trim().equals("") ){
		appendFilter += " and a.consecutivo = "+request.getParameter("consecutivo");
    	consecutivo = request.getParameter("consecutivo");
	} 
	if (request.getParameter("clase_comprob") != null && !request.getParameter("clase_comprob").trim().equals("") ){
		appendFilter += " and clase_comprob = "+request.getParameter("clase_comprob");
    	clase = request.getParameter("clase_comprob");
	}	
	if (request.getParameter("mes") != null && !request.getParameter("mes").trim().equals(""))
	{
		appendFilter += " and a.mes = "+request.getParameter("mes");
    	mes = request.getParameter("mes");
	} 
	
	String tableName = "";
	if(fg.equals("CD")) tableName = "tbl_con_encab_comprob";
	
	sql = "select a.ea_ano eaAno, a.consecutivo, a.compania,a.mes, a.clase_comprob claseComprob, a.descripcion, b.descripcion as descComprob, a.total_cr totalCr, a.total_db totalDb, nvl(a.n_doc,' ') as nDoc, decode(a.total_db,total_cr,1,0) fg, to_char(a.fecha_sistema,'dd/mm/yyyy') as fechaSistema, a.status, a.usuario"+(fg.equals("CD")?", a.tipo, a.estado":"") +"  from "+tableName+" a, tbl_con_clases_comprob b where  a.clase_comprob=b.codigo_comprob and  a.status ='PE' "+appendFilter + " and a.compania ="+((String) session.getAttribute("_companyId"))+" order by a.ea_ano desc, a.mes desc, a.consecutivo desc";
	//al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	al = sbb.getBeanList(ConMgr.getConnection(), "select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal, Comprobante.class);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Comprobante <%=(fg.equals("CD"))?"Diario":"Histórico"%> - '+document.title;

function add(){
	abrir_ventana('../contabilidad/reg_comp_diario.jsp?mode=add&fg=<%=fg%>&fp=<%=fp%>');
}

function view(id, anio, tipo){
	abrir_ventana('../contabilidad/reg_comp_diario.jsp?mode=view&no='+id+'&fg=<%=fg%>&fp=<%=fp%>&anio='+anio+'&tipo='+tipo);
}
function checkEstado()
{
  var chk = 0;
	var cantidad = 0;  
	<%if(fg.equals("CD")){%>
	for(i=0;i<<%=al.size()%>;i++)
	{
		var clase = eval('document.form1.claseComprob'+i).value;
		var anio = eval('document.form1.anio'+i).value;
		var mes = eval('document.form1.mes'+i).value;
		var compania = '<%=(String) session.getAttribute("_companyId")%>';
		if(eval('document.form1.check'+i).checked)
		{
		 if (!eval('document.form1.check'+i).disabled)chk++;
			var estado_mes =getDBData('<%=request.getContextPath()%>','nvl(estatus,\'CER\')','tbl_con_estado_meses','ano='+anio+' and cod_cia='+compania+' and mes = '+mes+' and estatus=\'ACT\'','');
			var estado_anio =getDBData('<%=request.getContextPath()%>','nvl(estado,\'CER\')','tbl_con_estado_anos','ano='+anio+' and cod_cia='+compania+' and estado=\'ACT\'','');
			
			if(estado_mes =='ACT')
			{
				cantidad ++;
			}
			else if(estado_mes =='CER' && estado_anio =='ACT' && (clase =='21' && clase =='22' && clase =='25' ) )
			{
				cantidad ++;
			}
			else {eval('document.form1.check'+i).checked = false;}
		}
	}
	if(chk == 0) {alert('Por favor seleccione al menos un comprobante');return false;} else{
	if(cantidad == 0){alert('El año o el mes de los comprobantes Selecciondos no existe o no está Activo Verifique!!');return false;}
	else{  return true;}}
	<%}else {%> return true;<%}%>
}
function checkAprob()
{
	var cantidad = 0;  
	<%if(fg.equals("CH")){%>
	
	var anio = document.search01.ea_ano.value;
	var mes  = document.search01.mes.value;
	var impuesto  = '';
	if(document.search01.impuesto[0].checked) impuesto =document.search01.impuesto[0].value ;
	else if(document.search01.impuesto[1].checked) impuesto =document.search01.impuesto[1].value ;
	alert('impuesto ==='+impuesto);

	
	var incentivo  = document.search01.incentivo.value;
	
	if(confirm('¿Esta seguro del IMPUESTO a Trabajar?'))
	{
	   if(anio !='')
	   {
	   		for(i=0;i<<%=al.size()%>;i++)
			{
				
				if(eval('document.form1.check'+i).checked && mes =='12')
				{	
					cantidad ++;
				}
			}
	   
	   }
	   else alert('Introduzca El Año');
	}
	else alert('Proceso Cancelado');
	
	
	if(cantidad == 0){alert('Seleccione los comprobantes a Mayorizar!!');return false;}
	else{alert(' Cantidad  De Comprobantes a Mayorizar=='+cantidad);
	document.form1.anio.value = anio ;
	document.form1.mes.value = mes;
	document.form1.impuesto.value=impuesto;
	document.form1.incentivo.value=incentivo;
	
	
	 return true};
	<%}else {%> return true;<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - REGISTRO COMPROBANTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;
	</td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="0" cellspacing="0">		
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
		<tr class="TextFilter">
			<td width="20%">
				A&ntilde;o:&nbsp;
				<%=fb.intBox("ea_ano",anio,false,false,false,10)%>
				&nbsp;Mes:&nbsp;<%=fb.select("mes","1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",((fg.equals("CH")))?"12":mes,false,true,0,null,null,"","","S")%>
			</td>
			<td width="15%">
				Consecutivo
				<%=fb.intBox("consecutivo",consecutivo,false,false,false,10)%>
			</td>
		
			<td width="65%">
				Clase
				<%=fb.select(ConMgr.getConnection(), "select codigo_comprob, codigo_comprob||'-'||descripcion descripcion from tbl_con_clases_comprob where tipo='C'","clase_comprob",clase,"S")%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
		<%=fb.formEnd()%>


		
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;<a href="javascript:printList()" class="Link00"><!--[ Imprimir Lista ]--></a></td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("mes",mes)%>

			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("mes",mes)%>

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
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
		<%=fb.hidden("size",""+al.size())%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("consecutivo",consecutivo)%>
		<%=fb.hidden("clase",clase)%>
		<%=fb.hidden("mes",mes)%>
		<%=fb.hidden("baction","")%>
	
		<tr class="TextHeader" align="center">
			<td width="4%">A&ntilde;o</td>
			<td width="6%">Consecutivo</td>
			<td width="8%">Mes</td>
			<td width="25%">Descripci&oacute;n</td>
			<td width="25%">Tipo Comprob.</td>
			<td width="8%">Total CR</td>
			<td width="8%">Total DB</td>
            <td width="5%">	<%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los Registros listados!")%>
			<td width="8%">&nbsp;</td>	
</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	Comprobante cdo = (Comprobante) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("consecutivo"+i,cdo.getConsecutivo())%>
		<%=fb.hidden("anio"+i,cdo.getEaAno())%>
		<%=fb.hidden("mes"+i,cdo.getMes())%>
		<%=fb.hidden("compania"+i,cdo.getCompania())%>
		<%=fb.hidden("claseComprob"+i,cdo.getClaseComprob())%>
		<%=fb.hidden("tipo"+i,cdo.getTipo())%>
		<%=fb.hidden("reg_type"+i,cdo.getRegType())%>		
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getEaAno()%></td>
			<td align="center"><%=cdo.getConsecutivo()%></td>
			<td align="center"><%=cdo.getMes()%></td>
			<td align="left"><%=cdo.getDescripcion()%></td>
			<td align="left"><%=cdo.getDescComprob()%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getTotalCr())%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getTotalDb())%>&nbsp;</td>
			<td align="center"><%=fb.checkbox("check"+i,""+i,false,cdo.getFg().equals("0"),"","","")%></td>
			<td align="center"> <authtype type='1'><a href="javascript:view(<%=cdo.getConsecutivo()%>,<%=cdo.getEaAno()%>,'<%=cdo.getTipo()%>')" class="Link02Bold">Ver</a></authtype> </td>
		</tr> 
<%
}
%>
		
		<tr class="TextRow02">
          <td colspan="9" align="right"><authtype type='6'><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  <%//=fb.button("save","Guardar",false,false,null,null,"onClick=\"javascript:checkEstado()\"")%></td>
        </tr>
		</table>
		<%if(fg.equals("CD")){fb.appendJsValidation("\n\tif (!checkEstado())\n\t{\n\t\terror++;\n\t}\n");}%>
		<%if(fg.equals("CH")){fb.appendJsValidation("\n\tif (!checkAprob())\n\t{\n\t\terror++;\n\t}\n");}%>


        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
</tr>

</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("mes",mes)%>

			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("consecutivo",consecutivo)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("mes",mes)%>

			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//End Method GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post
ArrayList al1= new ArrayList();
String fechaMod = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
 int size =Integer.parseInt(request.getParameter("size"));
 for(int i=0;i<size;i++)
 {
   if (request.getParameter("check"+i) != null)
   {
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_con_encab_comprob");
			
 		 	cdo.addColValue("consecutivo",request.getParameter("consecutivo"+i));
			cdo.addColValue("anio",request.getParameter("anio"+i));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("tipo",request.getParameter("tipo"+i));
			cdo.addColValue("reg_type",request.getParameter("reg_type"+i));
			
			cdo.addColValue("status","TR");//Estado temporal para el proceso de aprobacion...
			cdo.addColValue("usuario_aprob",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_a",fechaMod);
			cdo.addColValue("fg",fg);
			cdo.addColValue("p_user",(String) session.getAttribute("_userName"));
			al1.add(cdo);
	}
 }
	/*if(al1.size() == 0)
	{
		 CommonDataObject cdo = new CommonDataObject();
		 cdo.setTableName("tbl_con_encab_comprob");
		 cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" ");
		 al1.add(cdo);
	}*/
  	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());	
	CompMgr.aprobList(al1,fg);
	ConMgr.clearAppCtx(null);  
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (CompMgr.getErrCode().equals("1"))
{
%>
	alert('<%=CompMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/list_mg_aprob_comprobantes.jsp"))
	{
%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/list_mg_aprob_comprobantes.jsp")%>';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/contabilidad/list_mg_aprob_comprobantes.jsp?fg=<%=fg%>&fp=<%=fp%>';
<%
	}
%>
	//window.close();
<%
} else throw new Exception(CompMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
