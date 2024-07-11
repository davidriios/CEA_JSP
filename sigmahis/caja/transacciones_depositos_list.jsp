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
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900089") || SecMgr.checkAccess(session.getId(),"900090") || SecMgr.checkAccess(session.getId(),"900091") || SecMgr.checkAccess(session.getId(),"900092"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String codigo = request.getParameter("codigo");
String descripcion = request.getParameter("descripcion");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String usuario = request.getParameter("usuario");
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");
if(codigo==null) codigo = "";
if(descripcion==null) descripcion = "";
if(fechaini==null) fechaini = "";
if(fechafin==null) fechafin = "";
if(usuario==null) if(!fp.trim().equals("CONTA"))usuario = (String) session.getAttribute("_userName");else usuario="";
if(caja==null) caja = "";
if(turno==null) turno = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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

  if (!codigo.equals("")){
    appendFilter += " and upper(a.consecutivo_ag) like '%"+codigo.toUpperCase()+"%'";
  } 
  if (!descripcion.equals("")){
    appendFilter += " and upper(a.observacion) like '%"+descripcion.toUpperCase()+"%'";
  }
  if (!fechaini.equals("") ){
    appendFilter += " and trunc(a.f_movimiento)>= to_date('"+fechaini+"', 'dd/mm/yyyy')";
  }
  if (!fechafin.equals("")){
    appendFilter += " and trunc(a.f_movimiento) <= to_date('"+fechafin+"', 'dd/mm/yyyy')";
  }
  if (fp.trim().equals("CONTA"))appendFilter += " and dep_conta='S'";
  else appendFilter += " and a.caja is not null ";
  if (!usuario.trim().equals("")) { appendFilter +=" and upper(a.usuario_creacion) = '"+usuario.toUpperCase()+"'";}
  if (!caja.equals("")){   appendFilter += " and a.caja ="+caja; }
  if (!turno.equals("")){   appendFilter += " and a.turno ="+turno; }
  sql = "SELECT a.CONSECUTIVO_AG as codigo, a.BANCO, a.COMPANIA, a.CUENTA_BANCO as cuenta, to_char(a.F_MOVIMIENTO,'dd/mm/yyyy')as fecha, a.TIPO_MOVIMIENTO,a.MONTO, a.LADO, a.ESTADO_TRANS, a.OBSERVACION,a.caja ,a.descripcion||' - '||a.OBSERVACION as descripcion,nvl((select ca.descripcion from tbl_cja_cajas ca where ca.codigo=a.caja and  ca.compania=a.compania),'DEPOSITADO POR CONTABILIDAD') as nombrecaja, ban.nombre as nombrebanco, decode(dep_conta,'S','',decode(nvl(get_sec_comp_param(a.compania,'CJA_VALIDA_EDIT_DEP'),'S'),'S',(select estatus from  tbl_cja_turnos_x_cajas where compania=a.compania and cod_caja=a.caja and cod_turno =a.turno),'')) as  estadoTurno,nvl(get_sec_comp_param(a.compania,'CJA_VALIDA_EDIT_DEP'),'S') as valida_edicion,nvl(a.comprobante,'N') as comprobante  from tbl_con_movim_bancario a,tbl_con_tipo_movimiento b,tbl_con_banco ban where a.tipo_movimiento=1 and a.tipo_movimiento = b.cod_transac  and a.estado_trans = 'T' and a.estado_dep = 'DT' and a.compania = ban.compania and a.banco=ban.cod_banco and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+"order by a.f_movimiento desc";
 if(request.getParameter("fechafin")!=null){
  al = SQLMgr.getDataList(" select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
	//rowCount = CmnMgr.getCount(" SELECT count(*) FROM tbl_sal_recuperacion_anestesia "+appendFilter);
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
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Listado de Movimientos Bancarios- '+document.title;
function add(fp,fg){if(fp=='CONTA')abrir_ventana('../caja/registro_deposito_new.jsp?fp=<%=fp%>&fg='+fg);else abrir_ventana('../caja/registro_deposito.jsp?fp=<%=fp%>');}
function edit(id,cuenta,banco,caja,compania){abrir_ventana('../caja/registro_deposito.jsp?mode=edit&fp=<%=fp%>&consecutivo='+id+'&cuenta='+cuenta+'&banco='+banco+'&caja='+caja+'&compania='+compania);}
function ver(id,cuenta,banco,caja,compania,fp){if(fp=='CONTA')abrir_ventana('../caja/registro_deposito_new.jsp?mode=view&fp=<%=fp%>&consecutivo='+id+'&cuenta='+cuenta+'&banco='+banco+'&caja='+caja+'&compania='+compania);else abrir_ventana('../caja/registro_deposito.jsp?mode=view&fp=<%=fp%>&consecutivo='+id+'&cuenta='+cuenta+'&banco='+banco+'&caja='+caja+'&compania='+compania);}
function printList(){abrir_ventana('../caja/print_list_depositos.jsp?fp=<%=fp%>&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
function addTurnos(){abrir_ventana('../caja/reg_turnos_x_depositar.jsp?mode=add&fp=<%=fp%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="MOVIMIENTOS BANCARIOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;
	<%if(fp.trim().equals("CONTA")){%><authtype type='51'><a href="javascript:addTurnos()" class="Link00">[ <cellbytelabel>Editar Turnos</cellbytelabel> ]</a></authtype><authtype type='50'><a href="javascript:add('<%=fp%>','SUP')" class="Link00">[ <cellbytelabel>Registrar Dep&oacute;sito</cellbytelabel> ]</a></authtype><%}%>
	
	 <authtype type='3'><a href="javascript:add('<%=fp%>','AUX')" class="Link00">[ <cellbytelabel>Registrar Dep&oacute;sito</cellbytelabel> ]</a></authtype></td>
  </tr>
  <tr>
    <td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="1">
        <% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
        <%=fb.formStart()%>
        <tr class="TextFilter"> 
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
				<%=fb.hidden("fp",fp)%>
				<td>
           <cellbytelabel>C&oacute;digo</cellbytelabel> 
					<%=fb.intBox("codigo",codigo,false,false,false,10,null,null,null)%>
           &nbsp;&nbsp;<cellbytelabel>Observaci&oacute;n</cellbytelabel> 
					<%=fb.textBox("descripcion",descripcion,false,false,false,25,null,null,null)%>
            &nbsp;&nbsp;<cellbytelabel>Fecha</cellbytelabel> 
            <jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="2" />
            <jsp:param name="nameOfTBox1" value="fechaini" />
            <jsp:param name="valueOfTBox1" value="<%=fechaini%>" />
            <jsp:param name="nameOfTBox2" value="fechafin" />
            <jsp:param name="valueOfTBox2" value="<%=fechafin%>" />
            <jsp:param name="clearOption" value="true" />
            </jsp:include>
			&nbsp;&nbsp;Usuario<%=fb.textBox("usuario",usuario,false,false,false,15,null,null,null)%>
			&nbsp;&nbsp;Caja<%=fb.textBox("caja",caja,false,false,false,10,null,null,null)%>
			&nbsp;&nbsp;Turno<%=fb.textBox("turno",turno,false,false,false,10,null,null,null)%>
            <%=fb.submit("go","Ir")%>
          </td>
        </tr>
        <%=fb.formEnd()%>
      </table>
      <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
  <tr>
    <td align="right">&nbsp;<a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableTopBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextPager">
          <%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%> <%=fb.hidden("previousVal",""+(preVal-recsPerPage))%> <%=fb.hidden("fp",fp)%> <%=fb.hidden("searchOn",searchOn)%> <%=fb.hidden("searchVal",searchVal)%> <%=fb.hidden("searchValFromDate",searchValFromDate)%> <%=fb.hidden("searchValToDate",searchValToDate)%> <%=fb.hidden("searchType",searchType)%> <%=fb.hidden("searchDisp",searchDisp)%> <%=fb.hidden("searchQuery","sQ")%>
          <%=fb.hidden("codigo",codigo)%>
          <%=fb.hidden("descripcion",descripcion)%>
          <%=fb.hidden("fechaini",fechaini)%>
          <%=fb.hidden("fechafin",fechafin)%>
		  <%=fb.hidden("usuario",usuario)%>
		  <%=fb.hidden("caja",caja)%>
		  <%=fb.hidden("turno",turno)%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
          <td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
          <%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%> <%=fb.hidden("previousVal",""+(preVal+recsPerPage))%> <%=fb.hidden("fp",fp)%> <%=fb.hidden("searchOn",searchOn)%> <%=fb.hidden("searchVal",searchVal)%> <%=fb.hidden("searchValFromDate",searchValFromDate)%> <%=fb.hidden("searchValToDate",searchValToDate)%> <%=fb.hidden("searchType",searchType)%> <%=fb.hidden("searchDisp",searchDisp)%> <%=fb.hidden("searchQuery","sQ")%>
          <%=fb.hidden("codigo",codigo)%>
          <%=fb.hidden("descripcion",descripcion)%>
          <%=fb.hidden("fechaini",fechaini)%>
          <%=fb.hidden("fechafin",fechafin)%>
		  <%=fb.hidden("usuario",usuario)%>
		  <%=fb.hidden("caja",caja)%>
		  <%=fb.hidden("turno",turno)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableRightBorder"><!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader">
          <td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
          <td width="7%"><cellbytelabel>Fecha</cellbytelabel></td>
          <td width="25%"><cellbytelabel>Banco</cellbytelabel></td>
          <td width="20%"><cellbytelabel>Caja</cellbytelabel></td>
          <td width="8%"><cellbytelabel>Monto</cellbytelabel></td>
          <td width="25%"><cellbytelabel>Observación</cellbytelabel></td>
          <td width="5%">&nbsp;</td>
          <td width="5%">&nbsp;</td>
        </tr>
        <%
for (int i=0; i<al.size(); i++){
CommonDataObject cdo = (CommonDataObject) al.get(i);
String color = "TextRow02";
if (i % 2 == 0) color = "TextRow01";
%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><%=cdo.getColValue("codigo")%></td>
          <td><%=cdo.getColValue("fecha")%></td>
          <td><%=cdo.getColValue("nombrebanco")%></td>
          <td><%=cdo.getColValue("nombrecaja")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
          <td><%=cdo.getColValue("observacion")%></td>
          <td align="center">&nbsp;
            <%
	if (!fp.trim().equals("CONTA")){
 if (!cdo.getColValue("estadoTurno").trim().equals("I") ||(cdo.getColValue("estadoTurno").trim().equals("I")&& cdo.getColValue("valida_edicion").trim().equals("N"))){
 if(!cdo.getColValue("comprobante").trim().equals("S")){
%>
            <authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("cuenta")%>','<%=cdo.getColValue("banco")%>','<%=cdo.getColValue("caja")%>','<%=cdo.getColValue("compania")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype>
            <%}}
}
%></td>
          <td align="center">&nbsp;<authtype type='1'><a href="javascript:ver('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("cuenta")%>','<%=cdo.getColValue("banco")%>','<%=cdo.getColValue("caja")%>','<%=cdo.getColValue("compania")%>','<%=fp%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype></td>
        </tr>
        <% } %>
      </table>
      <!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextPager">
          <%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%> <%=fb.hidden("previousVal",""+(preVal-recsPerPage))%> <%=fb.hidden("fp",fp)%> <%=fb.hidden("searchOn",searchOn)%> <%=fb.hidden("searchVal",searchVal)%> <%=fb.hidden("searchValFromDate",searchValFromDate)%> <%=fb.hidden("searchValToDate",searchValToDate)%> <%=fb.hidden("searchType",searchType)%> <%=fb.hidden("searchDisp",searchDisp)%> <%=fb.hidden("searchQuery","sQ")%>
          <%=fb.hidden("codigo",codigo)%>
          <%=fb.hidden("descripcion",descripcion)%>
          <%=fb.hidden("fechaini",fechaini)%>
          <%=fb.hidden("fechafin",fechafin)%>
		  <%=fb.hidden("usuario",usuario)%>
		  <%=fb.hidden("caja",caja)%>
		  <%=fb.hidden("turno",turno)%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
          <td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
          <%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> <%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%> <%=fb.hidden("previousVal",""+(preVal+recsPerPage))%> <%=fb.hidden("fp",fp)%> <%=fb.hidden("searchOn",searchOn)%> <%=fb.hidden("searchVal",searchVal)%> <%=fb.hidden("searchValFromDate",searchValFromDate)%> <%=fb.hidden("searchValToDate",searchValToDate)%> <%=fb.hidden("searchType",searchType)%> <%=fb.hidden("searchDisp",searchDisp)%> <%=fb.hidden("searchQuery","sQ")%>
          <%=fb.hidden("codigo",codigo)%>
          <%=fb.hidden("descripcion",descripcion)%>
          <%=fb.hidden("fechaini",fechaini)%>
          <%=fb.hidden("fechafin",fechafin)%>
		  <%=fb.hidden("usuario",usuario)%>		  
		  <%=fb.hidden("caja",caja)%>
		  <%=fb.hidden("turno",turno)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
