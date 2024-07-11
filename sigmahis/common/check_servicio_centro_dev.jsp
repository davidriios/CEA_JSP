<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DetalleSolicitud"%>
<%@ page import="issi.facturacion.NotasAjustesDet"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iNotasCargo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vNotasCargo" scope="session" class="java.util.Vector" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);%><%
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100031") || SecMgr.checkAccess(session.getId(),"100032") || SecMgr.checkAccess(session.getId(),"100033") || SecMgr.checkAccess(session.getId(),"100034"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "", appendFilter1 = "";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String noAdmision = request.getParameter("noAdmision");
String cod_pac = request.getParameter("cod_pac");
String fec_nacimiento = request.getParameter("fec_nacimiento");
String pacienteId = request.getParameter("pacienteId");
String seccion = request.getParameter("seccion");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anio = cDateTime.substring(6,10);
String factura = request.getParameter("factura");
String nt = request.getParameter("nt");
String fg = request.getParameter("fg");
String tr = request.getParameter("tr");
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}
StringBuffer sbSql = new StringBuffer();

int cargoLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("cargoLastLineNo") != null) cargoLastLineNo = Integer.parseInt(request.getParameter("cargoLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{  appendFilter = ""; appendFilter1 = "";
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";

	if (request.getParameter("searchQuery")!= null)
	{  appendFilter = "";  appendFilter1 = "";
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
	if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
	if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}
	String cds ="",tipo_servicio="";
	if (request.getParameter("cds") != null && !request.getParameter("cds").trim().equals(""))
	{
		appendFilter += "and upper(a.centro) like '%"+request.getParameter("cds").toUpperCase()+"%'";
		cds = request.getParameter("cds");
	}
	if (request.getParameter("tipo_servicio") != null && !request.getParameter("tipo_servicio").trim().equals("")){
		appendFilter += "and upper(a.tipo) like '%"+request.getParameter("tipo_servicio").toUpperCase()+"%'";

		tipo_servicio = request.getParameter("tipo_servicio");
	}


 if (fp.equalsIgnoreCase("notas") && nt.trim().equals("D") )
	{


sbSql.append("select a.centro,  a.tipo,  sum(nvl (a.cantidad, 0)) as cantidad,  sum(nvl (a.monto_tramite, 0)) as montoTramite, sum(nvl (a.monto_cargo, 0)) as monto, sum(nvl(a.monto_tramite,0))+sum(nvl(a.monto_cargo,0)) as saldo, a.pac_id,  a.fac_secuencia, a.compania,  cc.descripcion as desccentro,  tt.descripcion as desctipo,   'C' as tipo_h   from  tbl_cds_centro_servicio cc,  tbl_cds_tipo_servicio tt,  ( select a.tipo_cargo as tipo, ");
if(cdsDet.trim().equals("S"))sbSql.append(" a.centro_servicio  ");
else sbSql.append(" b.centro_servicio  ");

sbSql.append("  as centro, 0 as monto_tramite, nvl(sum (decode(a.tipo_transaccion,'D',a.cantidad*-1,a.cantidad)), 0) as cantidad,  nvl (sum(nvl(decode(a.tipo_transaccion,'D',nvl(a.cantidad,0)*(a.monto+nvl(a.recargo,0))*-1,nvl(a.cantidad,0)*(a.monto+nvl(a.recargo,0))), 0)), 0) as monto_cargo,  a.pac_id,  a.fac_secuencia,  a.compania  from tbl_fac_detalle_transaccion a ,tbl_fac_transaccion b where  a.pac_id =");
sbSql.append(pacienteId);
sbSql.append("  and a.fac_secuencia =");
sbSql.append(noAdmision);
sbSql.append("  and a.compania =");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append("  and a.centro_servicio <> 0   and b.codigo=a.fac_codigo and b.pac_id=a.pac_id and b.admi_secuencia=a.fac_secuencia and b.compania=a.compania and b.tipo_transaccion=a.tipo_transaccion group by a.tipo_cargo,  a.tipo_transaccion,  ");
if(cdsDet.trim().equals("S"))sbSql.append(" a.centro_servicio  ");
else sbSql.append(" b.centro_servicio  ");

sbSql.append(",a.pac_id,a.fac_secuencia,a.compania");

sbSql.append(" union  all /*----AJUSTES APROB--->>*/  select a.service_type as tipo, a.centro as centro, 0 as monto_tramite, decode(a.lado_mov,'C',-1,1) as cantidad,nvl(sum( decode(a.lado_mov,'C',a.monto*-1,a.monto)),0)  as monto_ajuste,  a.pac_id,  a.amision, a.compania  from vw_con_adjustment_gral a   where     a.pac_id =");
sbSql.append(pacienteId);
sbSql.append("  and a.amision =");
sbSql.append(noAdmision);
sbSql.append("  and a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.factura ='");
sbSql.append(factura);
sbSql.append("'  and a.centro <> 0   group by a.service_type,  a.lado_mov,   a.centro,  a.pac_id,  a.amision,  a.compania ) a  where    a.centro = cc.codigo(+)       and a.tipo = tt.codigo(+)");
sbSql.append(appendFilter);
sbSql.append("   group by a.centro,a.tipo,a.pac_id,a.fac_secuencia,a.compania,cc.descripcion,tt.descripcion,'C' having (sum(nvl (a.monto_cargo, 0)) <> 0 or sum(nvl (a.monto_tramite, 0)) <> 0)") ;


al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");

}
	else  if (fp.equalsIgnoreCase("notas") && nt.trim().equals("H") )
	{


sql="select a.centro,a.tipo,a.codigo, sum(nvl(a.cantidad,0)) as cantidad, sum(nvl(a.monto_tramite,0)) as montoTramite, sum(nvl(a.monto_cargo,0)) as monto,  sum(nvl(a.monto_tramite,0))+sum(nvl(a.monto_cargo,0)) as saldo  ,a.pac_id, a.fac_secuencia, a.compania ,cc.descripcion as descCentro,tt.descripcion as descTipo,coalesce (e.nombre,m.primer_nombre||decode(m.segundo_nombre,null,'',' '||m.segundo_nombre)||' '||m.primer_apellido||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada)) )as nombre ,a.tipo_h from (select a.tipo_cargo as tipo,   a.centro_servicio as centro,   nvl (sum(nvl(decode(a.tipo_transaccion,'D',a.cantidad*-1,a.cantidad), 0)), 0) as cantidad,  0 as monto_tramite, nvl (sum (nvl (decode(a.tipo_transaccion,'D',nvl(a.cantidad,0)*a.monto*-1,nvl(a.cantidad,0)*a.monto), 0)), 0) as monto_cargo,   a.pac_id,  a.fac_secuencia,  a.compania,  b.empre_codigo as empresa,  b.med_codigo as medico,  decode (nvl(b.pagar_sociedad,'N'),  'N', b.med_codigo,  'S', b.empre_codigo)  as codigo,  decode (nvl(b.pagar_sociedad,'N'),  'N', 'M',  'S', 'E') as tipo_h   from tbl_fac_detalle_transaccion a, tbl_fac_transaccion b  where  a.pac_id ="+pacienteId+"        and a.fac_secuencia ="+noAdmision+"  and a.compania ="+(String) session.getAttribute("_companyId")+"  and a.centro_servicio = 0  and a.fac_codigo = b.codigo(+)  and a.pac_id = b.pac_id(+)  and a.fac_secuencia = b.admi_secuencia(+)  and b.compania(+) = a.compania  and b.centro_servicio = a.centro_servicio  and a.tipo_transaccion = b.tipo_transaccion(+)  group by a.tipo_cargo,  a.tipo_transaccion,  a.centro_servicio,  a.pac_id,  a.fac_secuencia,  a.compania,  b.empre_codigo,  b.med_codigo,  decode (nvl(b.pagar_sociedad,'N'),  'N', b.med_codigo,  'S', b.empre_codigo),  decode (nvl(b.pagar_sociedad,'N'),  'N', 'M',  'S', 'E')    union  all /**>>>ajustes aprob>>>**/   select a.service_type as tipo,  a.centro as centro,  decode(a.lado_mov,'C',-1,1) as cantidad,   0 as monto_tramite,    nvl (sum (nvl (decode(a.lado_mov,'C',a.monto*-1,a.monto), 0)), 0) as monto_ajuste,   a.pac_id,  a.amision,    a.compania, a.empresa, a.medico,  decode (a.tipo,  'H', a.medico,  'E', a.empresa) as codigo,    decode (a.tipo,  'H', 'M',  'E', 'E') as tipo_h   from vw_con_adjustment_gral a   where  a.pac_id ="+pacienteId+"   and a.amision ="+noAdmision+"  and a.compania ="+(String) session.getAttribute("_companyId")+"   and a.factura ='"+factura+"'  and a.centro = 0  and a.tipo in ('H', 'E')  and a.status = 'A'  group by a.service_type,  a.lado_mov,  a.centro,  a.pac_id,  a.amision,  a.compania, a.empresa, a.medico, decode (a.tipo,  'H', a.medico,  'E', a.empresa),  decode (a.tipo,  'H', 'M',  'E', 'E') ) a, tbl_cds_centro_servicio cc,tbl_cds_tipo_servicio tt,tbl_adm_medico m, tbl_adm_empresa e  where a.centro=cc.codigo(+)  and a.tipo=tt.codigo(+)  and a.medico=m.codigo(+)  and a.empresa=e.codigo(+)"+appendFilter+"  group by a.centro,a.tipo,a.codigo,a.pac_id, a.fac_secuencia, a.compania ,cc.descripcion,tt.descripcion,coalesce (e.nombre,m.primer_nombre||decode(m.segundo_nombre,null,'',' '||m.segundo_nombre)||' '||m.primer_apellido||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada)) ) ,a.tipo_h  having (sum(nvl (a.monto_cargo, 0)) <> 0  or sum(nvl (a.monto_tramite, 0)) <> 0)  order by 1,2";

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
	if (nxtVal<=rowCount)
	{ nVal=nxtVal;
	}
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;


%>
<html>
<head>
<%@ include file="nocache.jsp"%>
<%@ include file="header_param.jsp"%>
<script language="javascript">
document.title = 'Cargos  - '+document.title;

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
<jsp:include page="title.jsp" flush="true">
	<jsp:param name="title" value="CARGOS "></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="1">
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("mode",""+mode)%>
			<%=fb.hidden("size",""+al.size())%>
			<%=fb.hidden("cargoLastLineNo",""+cargoLastLineNo)%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("cod_pac",cod_pac)%>
			<%=fb.hidden("fec_nacimiento",fec_nacimiento)%>
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("pacienteId",pacienteId)%>
			<%=fb.hidden("fp",""+fp)%>
			<%=fb.hidden("nt",""+nt)%>
			<%=fb.hidden("fg",""+fg)%>
      <%=fb.hidden("tr",""+tr)%>

		<td width="50%"><cellbytelabel>C&oacute;digo Centro</cellbytelabel>
			<%=fb.textBox("cds",cds,false,false,false,30,null,null,null)%>
			</td>
		<td colspan="2"><cellbytelabel>Tipo Servicio</cellbytelabel>
					<%=fb.textBox("tipo_servicio",tipo_servicio,false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%></td>
		</tr>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
</table>
<!--------------------------------------------------------  --->
<table align="center" width="99%" cellpadding="1" cellspacing="0">
		<tr>
					<td align="right">&nbsp;</td>
	 </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("insumo",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("cargoLastLineNo",""+cargoLastLineNo)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("fec_nacimiento",fec_nacimiento)%>
<%=fb.hidden("pacienteId",pacienteId)%>
<%=fb.hidden("factura",factura)%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("nt",""+nt)%>
<%=fb.hidden("fg",""+fg)%>
<%=fb.hidden("tr",""+tr)%>
<%=fb.hidden("cds",""+cds)%>
<%=fb.hidden("tipo_servicio",""+tipo_servicio)%>

		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">



	<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>Centro</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Desc Centro</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;digo T.Servicio</cellbytelabel></td>
							<td width="20%"><cellbytelabel>Tipo Servicio</cellbytelabel></td>

							<%if(nt != null && nt.trim().equals("H")){%>
							<td width="30%"><cellbytelabel>M&eacute;dico/Empresa</cellbytelabel></td>
							<%}%>
							<td width="5%"><cellbytelabel>Cantidad</cellbytelabel></td>
							<td width="5%"><cellbytelabel>Monto</cellbytelabel></td>
							<td width="5%">&nbsp;</td>
	</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("centro"+i,cdo.getColValue("centro"))%>
		<%=fb.hidden("name_code"+i,cdo.getColValue("DescCentro"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("tipoServicio"+i,cdo.getColValue("tipo"))%>
		<%=fb.hidden("tipoDesc"+i,cdo.getColValue("descTipo"))%>
		<%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
		<%=fb.hidden("cantidad"+i,cdo.getColValue("cantidad"))%>
		<%=fb.hidden("tipo"+i,cdo.getColValue("tipo_h"))%>

		<%if(nt != null && nt.trim().equals("H")){%>
		<%=fb.hidden("codigo_h"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%}%>
		<tr class="<%=color%>">
				<td><%=cdo.getColValue("centro")%></td>
				<td><%=cdo.getColValue("descCentro")%></td>
				<td><%=cdo.getColValue("tipo")%></td>
				<td><%=cdo.getColValue("descTipo")%></td>

				<%if(nt != null && nt.trim().equals("H")){%>

							<td><%= cdo.getColValue("nombre")%> </td>
				<%}%>
				<td><%=cdo.getColValue("cantidad")%></td>
				<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
				<%if(nt != null && nt.trim().equals("D")){%>
				<td align="center"><%=(vNotasCargo.contains(cdo.getColValue("tipo")+"-"+cdo.getColValue("centro")))?"Elegido":fb.checkbox("check"+i,"",false,false)%></td>
				<%} else if(nt != null && nt.trim().equals("H")){%>
				<td align="center"><%=(vNotasCargo.contains(cdo.getColValue("tipo")+"-"+cdo.getColValue("centro")+"-"+cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,"",false,false)%></td>
				<%}%>
		</tr>
<%
}
%>
</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1 )?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount<=nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="footer.jsp"%>
</body>
</html>
<%
}//get
else
{
	int size = Integer.parseInt(request.getParameter("size"));


	int j =0;
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
					NotasAjustesDet nDet = new NotasAjustesDet();
					j = iNotasCargo.size();
					j++;

				 nDet.setUsuarioCreacion((String) session.getAttribute("_userName"));
				 nDet.setFechaCreacion(cDateTime);
				 nDet.setLadoMov("C");
					nDet.setFarhosp("N");
				 nDet.setCentro(request.getParameter("centro"+i));
				 nDet.setDescCentro(request.getParameter("name_code"+i));
				 nDet.setServiceType(request.getParameter("tipoServicio"+i));
				 nDet.setDescTipoServicio(request.getParameter("tipoDesc"+i));
				 nDet.setMonto(request.getParameter("monto"+i));
				 nDet.setMontoCargo(request.getParameter("monto"+i));
				 nDet.setSecuencia(""+j);
				 nDet.setDescripcion(request.getParameter("nombre"+i));

					if(nt != null && nt.trim().equals("H"))
					{
							 if(request.getParameter("tipo"+i)!=null && !request.getParameter("tipo"+i).trim().equals("") && request.getParameter("tipo"+i).trim().equals("M"))
							 {
									nDet.setMedico(request.getParameter("codigo_h"+i));
									nDet.setDetalleServicio(request.getParameter("codigo_h"+i));
									nDet.setTipo("H");
							 }
							 else if(request.getParameter("tipo"+i)!=null && !request.getParameter("tipo"+i).trim().equals("") && request.getParameter("tipo"+i).trim().equals("E"))
							 {
									nDet.setEmpresa(request.getParameter("codigo_h"+i));
									nDet.setDetalleServicio(request.getParameter("codigo_h"+i));
									nDet.setTipo("E");
							 }
					}else	nDet.setTipo("C");


			cargoLastLineNo++;
			String key = "";
			if (cargoLastLineNo < 10) key = "00"+cargoLastLineNo;
			else if (cargoLastLineNo < 100) key = "0"+cargoLastLineNo;
			else key = ""+cargoLastLineNo;
			try
			{
				iNotasCargo.put(key,nDet);
				if(nt != null && nt.trim().equals("H"))
				vNotasCargo.addElement(nDet.getServiceType()+"-"+nDet.getCentro()+"-"+nDet.getDetalleServicio());
				else
				vNotasCargo.addElement(nDet.getServiceType()+"-"+nDet.getCentro());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// if checked
	}//for
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&cargoLastLineNo="+cargoLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&fec_nacimiento="+request.getParameter("fec_nacimiento")+"&cod_pac="+request.getParameter("cod_pac")+"&pacienteId="+request.getParameter("pacienteId")+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&factura="+request.getParameter("factura")+"&fg="+request.getParameter("fg")+"&nt="+request.getParameter("nt")+"&tr="+request.getParameter("tr")+"&cds="+request.getParameter("cds")+"&tipo_servicio="+request.getParameter("tipo_servicio"));
			return;

	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&cargoLastLineNo="+cargoLastLineNo+"&noAdmision="+request.getParameter("noAdmision")+"&fec_nacimiento="+request.getParameter("fec_nacimiento")+"&cod_pac="+request.getParameter("cod_pac")+"&pacienteId="+request.getParameter("pacienteId")+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&factura="+request.getParameter("factura")+"&fg="+request.getParameter("fg")+"&nt="+request.getParameter("nt")+"&tr="+request.getParameter("tr")+"&cds="+request.getParameter("cds")+"&tipo_servicio="+request.getParameter("tipo_servicio"));

		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("notas"))
	{
%>
window.opener.location = '../facturacion/notas_ajuste_det.jsp?change=1&mode=<%=mode%>&pacienteId=<%=pacienteId%>&noAdmision=<%=noAdmision%>&fec_nacimiento=<%=fec_nacimiento%>&cod_pac=<%=cod_pac%>&cargoLastLineNo=<%=cargoLastLineNo%>&factura=<%=factura%>&nt=<%=nt%>&fg=<%=fg%>&tr=<%=tr%>';
<%
	}
%>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>
