<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FacDetTran"%>
<%@ page import="issi.admision.Beneficio"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="FacMgr" scope="page" class="issi.facturacion.FacturaMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="FacDet" scope="session" class="issi.facturacion.Factura" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500045") || SecMgr.checkAccess(session.getId(),"500046") || SecMgr.checkAccess(session.getId(),"500047") || SecMgr.checkAccess(session.getId(),"500048"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
FacMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdocount = new CommonDataObject();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
if(fg==null) fg = "";

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

FacMgr.updGNC(FacDet);

if (request.getMethod().equalsIgnoreCase("GET")){
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  /*
	if (request.getParameter("pasaporte") != null){
    appendFilter += " and upper(p.pasaporte) like '%"+request.getParameter("pasaporte").toUpperCase()+"%'";
    searchOn = "p.pasaporte";
    searchVal = request.getParameter("pasaporte");
    searchType = "2";
    searchDisp = "Pasaporte";
  }else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST")){
  	if (searchType.equals("2")){
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
  } else {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
	*/

	if (fp.equalsIgnoreCase("analisis_fact")){
		sql = "select a.secuencia, a.fac_fecha_nacimiento, a.fac_codigo_paciente, a.fac_secuencia, decode(a.centro_servicio, null, ' ', a.centro_servicio) centro_servicio, nvl(to_char(a.fecha_cargo,'dd/mm/yyyy hh24:mi:ss'),' ') as fecha_cargo, nvl(a.descripcion,' ') as descripcion, a.monto, decode(a.monto_clinica,null,' ',a.monto_clinica) as monto_clinica, nvl(a.tipo_val_cli,' ') as tipo_val_cli, decode(a.monto_paciente,null,' ',a.monto_paciente) as monto_paciente, nvl(a.tipo_val_pac,' ') as tipo_val_pac, decode(a.monto_empresa,null,' ',a.monto_empresa) as monto_empresa, nvl(a.tipo_val_emp,' ') as tipo_val_emp, nvl(a.no_cubierto,' ') as no_cubierto, nvl(a.tipo_transaccion,' ') as tipo_transaccion, decode(a.fac_codigo,null,' ',a.fac_codigo) as fac_codigo, b.descripcion centro_servicio_desc from tbl_fac_det_tran a, tbl_cds_centro_servicio b where a.centro_servicio = b.codigo and a.pac_id = "+FacDet.getPacId()+" and a.fac_secuencia = "+FacDet.getAdmiSecuencia()+ " order by a.centro_servicio";
	}

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
document.title = 'Gasos no cubiertos - '+document.title;

function setPaciente(k)
{
	if (eval('document.paciente.estatus'+k).value.toUpperCase() == 'I'){
		alert('No está permitido seleccionar pacientes inactivos!!');
	}	else {
<%
	if (fp.equals("analisis_fact")){
%>
<%
	}
	if (!fp.equals("analisis_fact")){
%>
		window.close();
<%
	}
%>
	}
}

function getMain(formx)
{
	formx.estado.value = document.search00.estado.value;
	formx.categoria.value = document.search00.categoria.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PACIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500047"))
//{
%>
	      <!--<a href="javascript:add()" class="Link00">[ Registrar Nuevo Paciente ]</a>-->
<%
//}
%>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">		
<%
fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<td>
						<cellbytelabel>Categor&iacute;a</cellbytelabel>
						<%//=fb.select(ConMgr.getConnection(), sqlCat, "categoria", categoria)%>
						<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>				
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
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
<%
fb = new FormBean("paciente","","post","");
%>
<%=fb.formStart()%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("fg",fg)%>
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td colspan="10" align="right"><%=fb.submit("add","Agregar")%></td>
				</tr>				
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="38%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="3%"><cellbytelabel>Pac</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Descuento</cellbytelabel></td>
					<td width="3%">%-$</td>
					<td width="10%"><cellbytelabel>Paciente</cellbytelabel></td>
					<td width="3%">%-$</td>
					<td width="10%"><cellbytelabel>Empresa</cellbytelabel></td>
					<td width="3%">%-$</td>
				</tr>				
<%
String centroServ = "";
int j = 0;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("fac_fecha_nacimiento"+i,cdo.getColValue("fac_fecha_nacimiento"))%>
				<%=fb.hidden("fac_codigo_paciente"+i,cdo.getColValue("fac_codigo_paciente"))%>
				<%=fb.hidden("fac_secuencia"+i,cdo.getColValue("fac_secuencia"))%>
				<%=fb.hidden("fac_codigo"+i,cdo.getColValue("fac_codigo"))%>
				<%=fb.hidden("centro_servicio"+i,cdo.getColValue("centro_servicio"))%>
				<%=fb.hidden("centro_servicio_desc"+i,cdo.getColValue("centro_servicio_desc"))%>
				<%=fb.hidden("tipo_transaccion"+i,cdo.getColValue("tipo_transaccion"))%>
				<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
				<%=fb.hidden("no_cubierto"+i,cdo.getColValue("no_cubierto"))%>
				<%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
				<%=fb.hidden("fecha_cargo"+i,cdo.getColValue("fecha_cargo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<%
				if(!centroServ.equals(cdo.getColValue("centro_servicio"))){
					if(i!=0){
					%>
						</table>
					</td>
				</tr>
					<%
					}
				%>
				<tr>
					<td colspan="10" onClick="javascript:showHide(<%=j%>)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td><%=cdo.getColValue("centro_servicio")%>-<%=cdo.getColValue("centro_servicio_desc")%></td>
							<td>&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="<%=j%>">
					<td colspan="10">
						<table width="100%" cellpadding="1" cellspacing="1">
				<%
					j++;
					centroServ = cdo.getColValue("centro_servicio");
				}
				%>
							<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="text-decoration:none; cursor:pointer">
								<td width="10%"><%=cdo.getColValue("fecha_cargo")%></td>
								<td width="38%"><%=cdo.getColValue("descripcion")%></td>
								<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;</td>
								<td width="3%" align="center"><%=fb.checkbox("chkCargo"+i,""+i,false, false, "", "", "")%></td>
								<td width="10%" align="center"><%=fb.decBox("monto_clinica"+i,cdo.getColValue("monto_clinica"),false,false,false,10)%></td>
								<td width="3%"><%=fb.select("tipo_val_cli"+i,"P=%,M=$","")%></td>
								<td width="10%" align="center"><%=fb.decBox("monto_paciente"+i,cdo.getColValue("monto_paciente"),false,false,false,10)%></td>
								<td width="3%"><%=fb.select("tipo_val_pac"+i,"P=%,M=$","")%></td>
								<td width="10%" align="center"><%=fb.decBox("monto_empresa"+i,cdo.getColValue("monto_empresa"),false,false,false,10)%></td>
								<td width="3%"><%=fb.select("tipo_val_emp"+i,"P=%,M=$","")%></td>
							</tr>				
<%
}
%>			
				<%
				if(al.size()>0){
				%>				
						</table>
					</td>
				</tr>
				<%
				}
				%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
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
}
else
{
	FacDet.getGastosNoCubiertos().clear();
	String artDel = "", key = "";;	
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	for(int i=0;i<keySize;i++){

		FacDetTran det = new FacDetTran();

		det.setFacFechaNacimiento(request.getParameter("fac_fecha_nacimiento"+i));
		det.setFacCodigoPaciente(request.getParameter("fac_codigo_paciente"+i));
		det.setFacSecuencia(request.getParameter("fac_secuencia"+i));
		det.setFacCodigo(request.getParameter("fac_codigo"+i));
		det.setTipoTransaccion(request.getParameter("tipo_transaccion"+i));
		det.setCentroServicio(request.getParameter("centro_servicio"+i));
		det.setCentroServicioDesc(request.getParameter("centro_servicio_desc"));
		det.setFechaCargo(request.getParameter("fecha_cargo"+i));
		det.setSecuencia(request.getParameter("secuencia"+i));
		det.setDescripcion(request.getParameter("descripcion"+i));
		det.setMonto(request.getParameter("monto"+i));
		//det.setMontoClinica(request.getParameter("monto_clinica"+i));
		det.setTipoValCli(request.getParameter("tipo_val_cli"+i));
		//det.setMontoPaciente(request.getParameter("monto_paciente"+i));
		det.setTipoValPac(request.getParameter("tipo_val_pac"+i));
		//det.setMontoEmpresa(request.getParameter("monto_empresa"+i));
		det.setTipoValEmp(request.getParameter("tipo_val_emp"+i));

		if(det.getCentroServicio().equals("110")){
			for(int j=0;j<FacDet.getBeneficios().size();j++){
				Beneficio ben = (Beneficio) FacDet.getBeneficios().get(j);
				
				if(ben.getTipoPlan().equals("2") && ben.getEmpresa().equals("21") && !ben.getTipoAdmi().equals("2")){
					sql = "select count(*) count1 from tbl_fac_detalle_transaccion a, tbl_sal_habitacion b, tbl_sal_cama c where a.habitacion = b.codigo and b.compania = c.compania and b.codigo = c.habitacion and a.habitacion = "+det.getHabitacion()+" and to_date(to_char(a.fecha_cargo,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+det.getFechaCargo()+"', 'dd/mm/yyyy') and a.pac_id = "+ FacDet.getPacId() + " and a.fac_secuencia = "+ FacDet.getAdmiSecuencia() +" and c.tipo_hab in (select tipo_habitacion from tbl_adm_detalle_cobertura where convenio = "+ben.getConvenio()+" and empresa = "+ ben.getEmpresa() +" and plan = "+ ben.getPlan() +" and categoria_admi = "+ FacDet.getCategoriaAdmi()+" and tipo_admi = "+ben.getTipoAdmi()+" and clasif_admi = " + FacDet.getClasifAdmi()+")";
					System.out.println("sql count1=\n"+sql);
					
					cdocount = (CommonDataObject) SQLMgr.getData(sql);
					ben.setCount1(cdocount.getColValue("count1"));
		
					sql = "select count(*) count2 from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.compania = b.compania and a.pac_id  = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion and a.codigo = b.fac_codigo and b.pac_id = " + FacDet.getPacId() + " and b.fac_secuencia = " + FacDet.getAdmiSecuencia() +" and a.centro_servicio in (11,46) /*salón de operaciones.*/ and b.tipo_cargo in ('10','05') and to_date(to_char(b.fecha_cargo,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('" + det.getFechaCargo()+"', 'dd/mm/yyyy')";
					System.out.println("sql count2=\n"+sql);
					
					cdocount = (CommonDataObject) SQLMgr.getData(sql);
					ben.setCount2(cdocount.getColValue("count2"));
					
				}
			}
		}
		
		if(request.getParameter("monto_clinica"+i)!=null && !request.getParameter("monto_clinica"+i).equals("null") && !request.getParameter("monto_clinica"+i).equals("")) det.setMontoClinica(request.getParameter("monto_clinica"+i));
		if(request.getParameter("monto_paciente"+i)!=null && !request.getParameter("monto_paciente"+i).equals("null") && !request.getParameter("monto_paciente"+i).equals("")) det.setMontoPaciente(request.getParameter("monto_paciente"+i));
		if(request.getParameter("monto_empresa"+i)!=null && !request.getParameter("monto_empresa"+i).equals("null") && !request.getParameter("monto_empresa"+i).equals("")) det.setMontoEmpresa(request.getParameter("monto_empresa"+i));
		
		if(request.getParameter("chkCargo"+i)!=null){
			det.setNoCubierto("S");

			try {
				FacDet.getGastosNoCubiertos().add(det);
				System.out.println("adding item "+key+" _ "+det.getCentroServicio());
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		
		}
	}

	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>