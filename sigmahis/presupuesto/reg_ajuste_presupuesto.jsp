<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.presupuesto.AjustePresupuesto"%>
<%@ page import="issi.presupuesto.AjusteDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCta" scope="session" class="java.util.Vector"/>
<jsp:useBean id="AjMgr" scope="page" class="issi.presupuesto.AjustePresupuestoMgr"/>
<%
/**
==================================================================================
fg= PO  --->  Registro de Ajuste al Presupuesto Operativo  PRESF011
fg= PO  --->  Registro de Ajuste al Presupuesto de Inversiones  PRESF010
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
AjMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
AjustePresupuesto ajPres = new AjustePresupuesto();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");

String change = request.getParameter("change");
String anio = request.getParameter("anio");
String codAjuste = request.getParameter("codAjuste");
String compania = request.getParameter("compania");
String noAjuste = request.getParameter("noAjuste");

boolean viewMode = false;
int lastLineNo = 0;
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;
if(anio ==null)anio=cDateTime.substring(6, 10);
if(compania ==null)compania=(String) session.getAttribute("_companyId");
if(fg ==null)fg="PO";
String fgLabel ="";
String tableName = "";
	if(fg.trim().equals("PO")){
		tableName="tbl_con_ajuste_cta";fgLabel="PRESUPUESTO OPERATIVO";}
	else if(fg.trim().equals("PI")){ tableName="tbl_con_ajuste_cta_inv";fgLabel="PRESUPUESTO DE INVERSIONES";}

if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change == null)
	{
			iCta.clear();
			vCta.clear();

			if (mode.equalsIgnoreCase("add"))
			{

				ajPres.setAnio(anio);
				ajPres.setFechaSistema(cDateTime.substring(0,10));
				ajPres.setFechaDocumento(cDateTime.substring(0,10));
				ajPres.setUsuario((String) session.getAttribute("_userName"));
				ajPres.setNoAjuste("0");
				ajPres.setMonto("");
				//ajPres.setEstado("B");
				//ajPres.setFg(fg);

			}
			else
			{

		sql = "select a.anio, a.cod_ajuste codAjuste, a.numero_ajuste noAjuste,a.explicacion, a.monto, a.mes,to_char(a.fecha_documento,'dd/mm/yyyy')fechaDocumento, to_char(a.fecha_sistema,'dd/mm/yyyy') fechaSistema, a.usuario, a.estado, a.numero_documento  numeroDocumento from "+tableName+" a where a.anio="+anio+" and a.cod_ajuste="+codAjuste+" and a.numero_ajuste="+noAjuste;

			System.out.println("Encab ajPres =\n"+sql);
			ajPres = (AjustePresupuesto) sbb.getSingleRowBean(ConMgr.getConnection(),sql,AjustePresupuesto.class);


	if(fg.trim().equals("PO"))
	{
			sql="select lpad(rownum,4,'0') as key,  a.anio, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.compania, a.mes, a.anio_a anioA, a.cod_ajuste codAjuste, a.numero_ajuste noAjuste, a.movimiento, a.monto_origen montoOrigen, a.compania_origen companiaOrigen,(select (nvl(mm.traslado,0) + nvl(mm.asignacion,0) + nvl(mm.redistribuciones,0) - nvl(mm.consumido,0)) dspAsignacion from tbl_con_cuenta_mensual mm where  mm.anio = a.anio and mm.cta1 = a.cta1 and mm.cta2 = a.cta2 and mm.cta3 = a.cta3 and mm.cta4 = a.cta4 and mm.cta5 = a.cta5 and mm.cta6 = a.cta6 and mm.compania = a.compania  and mm.mes = a.mes )dspAsignacion,(select cg.descripcion from  tbl_con_catalogo_gral cg where (cg.cta1 =  a.cta1 and cg.cta2 =  a.cta2 and cg.cta3 =  a.cta3 and cg.cta4 =  a.cta4 and cg.cta5 =  a.cta5 and cg.cta6 =  a.cta6 and cg.compania =  nvl(a.compania_origen,a.compania))) descCuenta ,a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 numCuenta from tbl_con_detalle_ajuste_cta a where anio ="+anio+" and a.cod_ajuste = "+codAjuste+" and a.numero_ajuste ="+noAjuste;

	}
	else if(fg.trim().equals("PI"))
	{
					sql="select lpad(rownum,4,'0') as key,  a.anio, a.compania, a.mes, a.anio_im anioIm, a.cod_ajuste codAjuste,a.consec, a.numero_ajuste noAjuste, a.movimiento, a.tipo_inv tipoInv, a.codigo_ue codigoUe ,a.monto_origen montoOrigen,(select (nvl(mm.traslado,0) + nvl(mm.aprobado,0) + nvl(mm.redistribuciones,0) - nvl(mm.ejecutado,0)) dspAsignacion from tbl_con_inversion_mensual mm where  mm.anio = a.anio and mm.compania = a.compania  and mm.mes = a.mes and codigo_ue=a.codigo_ue and consec=a.consec and mm.tipo_inv=a.tipo_inv) dspAsignacion,(select descripcion from  tbl_sec_unidad_ejec where codigo=a.codigo_ue and compania=a.compania)descUnidad,(select descripcion from tbl_con_inversion_mensual mm where  mm.anio = a.anio and mm.compania = a.compania  and mm.mes = a.mes and codigo_ue=a.codigo_ue and consec=a.consec and mm.tipo_inv=a.tipo_inv ) descCuenta from tbl_con_det_ajust_cta_inv a where anio ="+anio+" and a.cod_ajuste = "+codAjuste+" and a.numero_ajuste ="+noAjuste+" order by a.anio,a.mes,a.tipo_inv,a.consec ";


	}

			System.out.println("Det=\n"+sql);
			ajPres.setAjusteDetail(sbb.getBeanList(ConMgr.getConnection(), sql, AjusteDetail.class));

			lastLineNo = ajPres.getAjusteDetail().size();
			for (int i=0; i<ajPres.getAjusteDetail().size(); i++)
			{
				AjusteDetail ajPresDet = (AjusteDetail) ajPres.getAjusteDetail().get(i);

				try
				{
					iCta.put(ajPresDet.getKey(), ajPresDet);
					if(fg.trim().equals("PO"))vCta.add(ajPresDet.getCompania()+"-"+ajPresDet.getAnio()+"-"+ajPresDet.getMes()+"-"+ajPresDet.getCta1()+"-"+ajPresDet.getCta2()+"-"+ajPresDet.getCta3()+"-"+ajPresDet.getCta4()+"-"+ajPresDet.getCta5()+"-"+ajPresDet.getCta6());
					else if(fg.trim().equals("PI")) vCta.add(ajPresDet.getCompania()+"-"+ajPresDet.getAnio()+"-"+ajPresDet.getMes()+"-"+ajPresDet.getCodigoUe()+"-"+ajPresDet.getConsec()+"-"+ajPresDet.getCta3()+"-"+ajPresDet.getCta4()+"-"+ajPresDet.getCta5()+"-"+ajPresDet.getCta6());


				}
				catch (Exception e)
				{
					System.out.println("Unable to addget cta "+key);
				}
			}



			}
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="PRESUPUESTO - "+document.title;

function doSubmit(baction)
{
	document.form1.baction.value = baction;
	window.frames['itemFrame'].doSubmit();
}
function printPres(){
	 //abrir_ventana("../presupuesto/print_presupuesto_ope.jsp?anio=<%=anio%>");
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PRESUPUESTO - REGISTRO DE AJUSTES A PRESUPUESTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+ ajPres.getAjusteDetail().size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("usuario",""+ajPres.getUsuario())%>


<tr>
	<td class="TableBorder">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader01">
			<td colspan="6"><cellbytelabel>AJUSTE A CUENTA DEL</cellbytelabel> <%=fgLabel%></td>
		</tr>
		<tr class="TextRow01">
			<td>Fecha</td>
			<td><jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="fechaSistema"/>
				<jsp:param name="valueOfTBox1" value="<%=ajPres.getFechaSistema()%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="readonly" value="y"/>
				</jsp:include></td>
			<td><cellbytelabel>N&uacute;mero de Ajuste</cellbytelabel></td>
			<td colspan="3"><%=fb.textBox("anio",ajPres.getAnio(),true,false,true,10)%>
			<%=fb.textBox("noAjuste",ajPres.getNoAjuste(),false,false,true,10)%></td>
		</tr>
		<tr class="TextRow02">
			<td width="15%"><cellbytelabel>Fecha Documento</cellbytelabel></td>
			<td width="25%">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="fechaDocumento"/>
				<jsp:param name="valueOfTBox1" value="<%=ajPres.getFechaDocumento()%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include></td>
			<td width="15%"><cellbytelabel>N&uacute;mero de Documento</cellbytelabel></td>
			<td width="25%"><%=fb.textBox("numeroDocumento",ajPres.getNumeroDocumento(),false,false,viewMode,10)%>
			<td width="15%"><cellbytelabel>Mes del Ajuste</cellbytelabel></td>
			<td width="15%"><%=fb.textBox("mes",ajPres.getMes(),true,false,viewMode,10)%></td>
		</tr>

		<tr class="TextRow01">
			<td><cellbytelabel>Tipo De Ajuste</cellbytelabel></td>
			<td colspan="2"><%//=fb.textBox("compania",pres.getCompania(),true,false,viewMode,10)%>
							<%//=fb.textBox("descCompania",pres.getDescCompania(),true,false,viewMode,40)%>
							<%=fb.select(ConMgr.getConnection(), "select cod_ajuste, descripcion from tbl_con_tipo_ajuste", "codAjuste",ajPres.getCodAjuste(),false,viewMode, 0, "text10", "", "")%>
							<%//=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:selCuenta()\"")%></td>
			<td><cellbytelabel>Monto</cellbytelabel></td>
			<td colspan="2"><%=fb.decBox("monto",ajPres.getMonto(),true,false,viewMode,10,null,null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("estado","T=TRAMITE,A=APROBADO,R=RECHAZADO",ajPres.getEstado(),false,viewMode,0,null,null,null,"","")%></td>

			<td rowspan="3"><cellbytelabel>Justificaci&oacute;n</cellbytelabel></td>
			<td colspan="4" rowspan="3"><%=fb.textarea("explicacion",ajPres.getExplicacion(),true,false,viewMode,80,5,2000)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Total de entradas</cellbytelabel>:</td>
			<td><%=fb.decBox("totalEntradas","0",false,false,true,20,null,null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Total de Salidas</cellbytelabel>:</td>
			<td><%=fb.decBox("totalSalidas","0",false,false,true,20,null,null,"")%></td>
		</tr>
		<tr>
			<td colspan="6">
				<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../presupuesto/reg_ajuste_presupuesto_det.jsp?mode=<%=mode%>&fg=<%=fg%>&lastLineNo=<%=lastLineNo%>"></iframe><!---->
			</td>
		</tr>


		<tr class="TextRow02">
			<td colspan="6" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<!--<%=fb.radio("saveOption","O")%>Mantener Abierto -->
				<%=fb.radio("saveOption","C",true,viewMode,viewMode)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>

	</td>
</tr>
<%=fb.formEnd(true)%>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	if (!request.getParameter("errCode").trim().equals(""))
	{
		AjMgr.setErrCode(request.getParameter("errCode"));
		AjMgr.setErrMsg(request.getParameter("errMsg"));
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (AjMgr.getErrCode().equals("1"))
{
%>
	alert('<%=AjMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/list_ajustes_presupuestarios.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/list_ajustes_presupuestarios.jsp")%>&fg=<%=fg%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/presupuesto/list_ajustes_presupuestarios.jsp?fg=<%=fg%>';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(AjMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>