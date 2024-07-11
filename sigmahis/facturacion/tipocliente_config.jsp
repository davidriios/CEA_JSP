<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================
900087	AGREGAR TIPO CLIENTE
900088	MODIFICAR TIPO CLIENTE
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id=request.getParameter("code");
String fg=request.getParameter("fg");

if (mode == null) mode = "add";
if (fg == null) fg = "RTC";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de Cliente no es válido. Por favor intente nuevamente!");

		sql = "select a.codigo, a.descripcion,a.porcentaje_recargo porcentaje, a.impuesto, a.activo_inactivo as estado,a.cta1,a.cta2,a.cta3,a.cta4,a.cta5,a.cta6 , b.descripcion cuentaDes, a.refer, a.refer_to, a.es_clt_cr, nvl(a.usa_nivel_precio_gen, 'N') usa_nivel_precio_gen, nvl(a.usa_nivel_precio_caf, 'N') usa_nivel_precio_caf, nvl(a.usa_nivel_precio_far, 'N') usa_nivel_precio_far,nvl(afecta_aux,'N') as afecta_aux,nvl(a.resp_pac,'N')as resp_pac,nvl(a.resp_pos,'N') as resp_pos FROM tbl_fac_tipo_cliente a , tbl_con_catalogo_gral b WHERE a.cta1 = b.cta1(+) and a.cta2 = b.cta2(+)  and a.cta3 = b.cta3(+) and a.cta4 = b.cta4(+) and a.cta5 = b.cta5(+)and a.cta6 = b.cta6(+) and a.compania = b.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.codigo="+id;
				cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Tipo de Cliente Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipo de Cliente Edición - "+document.title;
<%}%>

function getCta()
{
	abrir_ventana1('../common/search_catalogo_gral.jsp?fp=tipoCliente');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
      <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("fg",fg)%>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="85%"><%=id%></td>
				</tr>
				<tr class="TextRow01">
				    <td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
 			        <td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,50)%></td>
				</tr>
				<%if(fg.trim().equals("REP")){%>
				<tr class="TextRow01">
				    <td><cellbytelabel>Compañia</cellbytelabel></td>
 			        <td><%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT codigo,nombre||' - '||codigo from tbl_sec_compania c where not exists (select null from tbl_fac_tipo_cliente where codigo = "+id+" and compania = c.codigo ) ORDER BY 1 ","compania","",true,false,false,0)%></td>
				        
				</tr>
					
				<%}else{%>
				<%=fb.hidden("compania",""+(String) session.getAttribute("_companyId"))%>
				<%}%>
				<tr class="TextRow01">
					<td>% <cellbytelabel>Recargo</cellbytelabel></td>
					<td><%=fb.decBox("porcentaje",cdo.getColValue("porcentaje"),false,false,false,50)%></td>
				</tr>
				<tr class="TextRow01">
					<td>% <cellbytelabel>Impuesto</cellbytelabel></td>
					<td><%=fb.decBox("impuesto",cdo.getColValue("impuesto"),false,false,false,50)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Estado</cellbytelabel></td>
					<td><%=fb.select("estado","A=ACTIVO, I=INACTIVO",cdo.getColValue("estado"))%></td>
				</tr>
        		<%if(fg.trim().equals("RTC")){%>
				<tr class="TextRow01">
					<td><cellbytelabel>Cuenta</cellbytelabel></td>
					<td>	<%=fb.textBox("cta1",cdo.getColValue("cta1"),false,false,true,3,"Text10",null,"")%>
								<%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,true,2,"Text10",null,"")%>
								<%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,true,3,"Text10",null,"")%>
								<%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,true,3,"Text10",null,"")%>
								<%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,true,3,"Text10",null,"")%>
								<%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,3,"Text10",null,"")%>
                <%=fb.textBox("cuentaDes",cdo.getColValue("cuentaDes"),false,false,true,60,"Text10",null,"")%>

								<%=fb.button("btnCta","...",true,false,null,null,"onClick=\"javascript:getCta()\"")%></td>
				</tr>
				<%}%>

				<tr class="TextRow01">
					<td><cellbytelabel>Tipo Recibo</cellbytelabel></td>
					<td><%=fb.select("refer","P=ADMISION PACIENTE, O=OTROS, E=ADMISION EMPRESA",cdo.getColValue("refer"),false,true,0,"",null,null,null,"S")%></td>
				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel>Tipo Referencia</cellbytelabel></td>
					<td><%=fb.select("refer_to","EMPL=EMPLEADO, EMPR=ASEGURADORA, MED=MEDICO, PART=PARTICULAR, CDST=CENTRO SERV. TECERO, CDS=CENTRO SERV. INTERNO, COMP=INTERCOMPAÑIA, PAC=PACIENTE, ALQ=CONTRATO ALQUILER, DPTO=DEPARTAMENTO, CXCO=CXC OTROS, CXPP=CXP PROVEEDOR, CXPO=CXP OTROS,EMPO=COLABORADOR OTROS,PLAN=PLAN MEDICO,EMPRSM=SOCIEDADES MEDICAS",cdo.getColValue("refer_to"),false,true,0,"",null,null,null,"S")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Es Cliente Cr&eacute;dito</cellbytelabel>:</td>
					<td><%=fb.select("es_clt_cr","N=No, S=Si",cdo.getColValue("es_clt_cr"))%></td>
				</tr>
				<tr class="TextRow01"><td colspan="2"><table width="100%">
				<tr class="TextRow01"><td colspan="6">Par&aacute;metros para los POS</td></tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Usa Nivel de Precio (POS GENERAL)</cellbytelabel>:</td>
					<td><%=fb.select("usa_nivel_precio_gen","N=No, S=Si",cdo.getColValue("usa_nivel_precio_gen"))%></td>
					<td align="right"><cellbytelabel>Usa Nivel de Precio (POS CAFETERIA)</cellbytelabel>:</td>
					<td><%=fb.select("usa_nivel_precio_caf","N=No, S=Si",cdo.getColValue("usa_nivel_precio_caf"))%></td>
					<td align="right"><cellbytelabel>Usa Nivel de Precio (POS FARMACIA)</cellbytelabel>:</td>
					<td><%=fb.select("usa_nivel_precio_far","N=No, S=Si",cdo.getColValue("usa_nivel_precio_far"))%></td>
				</tr>

				</table></td></tr>

		<tr class="TextRow01">
					<td><cellbytelabel>Afecta Auxiliar</cellbytelabel></td>
					<td><%=fb.select("afecta_aux","N=NO,S=SI",cdo.getColValue("afecta_aux"))%></td>
		</tr>
		<tr class="TextRow01">
					<td><cellbytelabel>Responsable de Cuentas de Paciente</cellbytelabel></td>
					<td><%=fb.select("resp_pac","N=NO,S=SI",cdo.getColValue("resp_pac"))%></td>
		</tr><tr class="TextRow01">
					<td><cellbytelabel>Responsable de Cuentas del POS</cellbytelabel></td>
					<td><%=fb.select("resp_pos","N=NO,S=SI",cdo.getColValue("resp_pos"))%></td>
		</tr>
		<tr  class="TextRow02">
			<td colspan="2">
				<jsp:include page="../common/bitacora.jsp?audCollapsed=n" flush="true">
					<jsp:param name="audTable" value="tbl_fac_tipo_cliente"></jsp:param>
					<jsp:param name="audFilter" value="<%="compania="+(String) session.getAttribute("_companyId")+" and codigo="+id%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>

                <tr class="TextRow02">
			        <td colspan="2" align="right">
				    <%=fb.submit("save","Guardar",true,false)%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_fac_tipo_cliente");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("porcentaje_recargo",request.getParameter("porcentaje"));
  cdo.addColValue("impuesto",request.getParameter("impuesto"));
  cdo.addColValue("activo_inactivo",request.getParameter("estado"));
  if (mode.equalsIgnoreCase("add")||fg.trim().equals("REP")){
  cdo.addColValue("refer",request.getParameter("refer"));
  cdo.addColValue("refer_to",request.getParameter("refer_to"));
  }
  cdo.addColValue("afecta_aux",request.getParameter("afecta_aux"));
  cdo.addColValue("resp_pac",request.getParameter("resp_pac"));
  cdo.addColValue("resp_pos",request.getParameter("resp_pos"));

	cdo.addColValue("cta1",request.getParameter("cta1"));
	cdo.addColValue("cta2",request.getParameter("cta2"));
	cdo.addColValue("cta3",request.getParameter("cta3"));
	cdo.addColValue("cta4",request.getParameter("cta4"));
	cdo.addColValue("cta5",request.getParameter("cta5"));
	cdo.addColValue("cta6",request.getParameter("cta6"));
	cdo.addColValue("es_clt_cr",request.getParameter("es_clt_cr"));
	cdo.addColValue("usa_nivel_precio_gen",request.getParameter("usa_nivel_precio_gen"));
	cdo.addColValue("usa_nivel_precio_caf",request.getParameter("usa_nivel_precio_caf"));
	cdo.addColValue("usa_nivel_precio_far",request.getParameter("usa_nivel_precio_far"));

 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
  if (mode.equalsIgnoreCase("add")||fg.trim().equals("REP"))
  {
    cdo.addColValue("compania",request.getParameter("compania"));
	if(fg.trim().equals("RTC"))cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
	if(fg.trim().equals("RTC"))cdo.setAutoIncCol("codigo");else cdo.addColValue("codigo",request.getParameter("id"));
	
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("codigo="+request.getParameter("id")+" and compania="+(String) session.getAttribute("_companyId"));
	SQLMgr.update(cdo);
  }
 ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/tipocliente_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/tipocliente_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/tipocliente_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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