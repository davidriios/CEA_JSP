<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.presupuesto.Compromisos"%>
<%@ page import="issi.presupuesto.CompDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCta" scope="session" class="java.util.Vector" />
<jsp:useBean id="CompMgr" scope="page" class="issi.presupuesto.CompromisosMgr" />
<%
/**
==================================================================================
fg --> CF  --->  Registro de Compromisos al Presupuesto De Inversiones
fg --> AC  --->  Ajustes a los Compromisos formales de Inversiones
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CompMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Compromisos compPres = new Compromisos();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");

String change = request.getParameter("change");
String anio = request.getParameter("anio");
String tipoCom = request.getParameter("tipoCom");
String noDoc = request.getParameter("noDoc");

boolean viewMode = false;
int lastLineNo = 0;
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;
if(anio ==null)anio=cDateTime.substring(6, 10);
if(fg ==null)fg="CF";
String fgLabel ="";
String tableName = "";
	if(fg.trim().equals("CF"))fgLabel="Compromiso de Inversion";
	else fgLabel="Ajustes a los Compromiso de Inversion";

if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change == null)
	{
			iCta.clear();
			vCta.clear();
			
			if (mode.equalsIgnoreCase("add"))
			{
				
				compPres.setAnio(anio);
				compPres.setFechaSistema(cDateTime.substring(0,10));
				compPres.setFechaDocumento(cDateTime.substring(0,10));
				compPres.setFechaMod(cDateTime);
				compPres.setUsuario((String) session.getAttribute("_userName"));
				compPres.setUsuarioMod((String) session.getAttribute("_userName"));
				compPres.setNumDoc("0");
				compPres.setMonto("0");
				//compPres.setEstado("B");
				//compPres.setFg(fg);
			}
			else 
			{

  if(fg.trim().equals("CF"))
  {		
	sql = "select a.anio, a.tipo_com tipoCom, a.num_doc numDoc , a.estado, a.mes, a.monto_total monto ,to_char(a.fecha_documento,'dd/mm/yyyy')fechaDocumento, to_char(a.fecha_sistema,'dd/mm/yyyy hh12:mi:ss am') fechaSistema, a.usuario,to_char(a.fecha_mod,'dd/mm/yyyy hh12:mi:ss am') fechaMod, a.usuario_mod usuarioMod , a.explicacion,(select descripcion from tbl_com_tipo_compromiso where tipo_com = a.tipo_com)descTipoCom,decode(a.estado,'COM','COMPROMETIDO','PAG','PAGADO','ANU','ANULADO') descEstado from tbl_con_comp_formal_inversion a where a.anio="+anio+" and a.tipo_com="+tipoCom+" and a.num_doc="+noDoc;
  }
  else if(fg.trim().equals("AC"))
  {
  		sql = "select a.anio, a.numero_documento numDoc, to_char(a.fecha_documento,'dd/mm/yyyy')fechaDocumento,a.mes, a.monto_anterior montoAnterior, a.monto_ajustado montoAjustado, a.estado, a.explicacion, a.anio_ref anioRef,a.tipo_com_ref tipoCom, a.num_doc_ref numDocRef, (select decode (sum(nvl(co.monto_original,0)) + sum(nvl(co.monto_de_ajuste,0)),0,null,tc.descripcion) dsp_descripcion from tbl_con_compromiso_inversion co,tbl_com_tipo_compromiso tc where tc.tipo_com = co.tipo_com and co.tipo_com=a.tipo_com_ref and co.anio = a.anio_ref  and co.num_doc = a.num_doc_ref )descripcion from tbl_con_ajuste_inv_comp a where a.anio="+anio+" and a.numero_documento="+noDoc;

  }

			System.out.println("Encab compPres =\n"+sql);
			compPres = (Compromisos) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Compromisos.class);

				
  if(fg.trim().equals("CF"))
  {		
      sql="select c.anio_cfi anioCfi, c.tipo_com tipoCom, c.num_doc numDoc ,c.anio, c.tipo_inv tipoInv, c.compania,c.codigo_ue codigoUe, c.consec, c.mes,c.monto_original montoOriginal, c.estado, c.monto_de_ajuste montoAjuste,c.usuario_mod usuarioMod,to_char(c.fecha_mod,'dd/mm/yyyy hh12:mi:ss am') fechaMod ,(select descripcion from tbl_sec_unidad_ejec where codigo =c.codigo_ue and compania = c.compania) descUnidad,nvl((select nvl(aprobado,0) - nvl(ejecutado,0) from tbl_con_inversion_mensual where anio = c.anio and tipo_inv = c.tipo_inv and compania = c.compania and codigo_ue = c.codigo_ue and consec = c.consec and mes = c.mes),0)saldo,nvl((select descripcion from tbl_con_inversion_mensual where anio = c.anio and tipo_inv = c.tipo_inv and compania = c.compania and codigo_ue = c.codigo_ue and consec = c.consec and mes = c.mes),0)descripcion from tbl_con_compromiso_inversion c where c.anio_cfi ="+anio+" and c.tipo_com = "+tipoCom+" and c.num_doc="+noDoc;
	
  }
  else if(fg.trim().equals("AC"))
  {
	sql="select  d.aic_anio aicAnio, d.numero_documento numeroDocumento, d.anio_cfi anioCfi,d.tipo_com tipoCom, d.num_doc numDoc, d.anio,d.tipo_inv tipoInv, d.compania, d.codigo_ue codigoUe,d.consec, d.mes, d.estado,nvl(d.monto_original,0) montoOriginal, nvl(d.monto_ajustado,0) montoAjustado,(select descripcion from tbl_sec_unidad_ejec where codigo =d.codigo_ue and compania = d.compania) descUnidad,(select descripcion from tbl_com_tipo_compromiso where tipo_com = d.tipo_com)descTipoCom from tbl_con_det_ajust_inv_comp d where d.aic_anio= "+anio+" and d.numero_documento="+noDoc;
  }
			
			System.out.println("Det=\n"+sql);
			compPres.setCompDetail(sbb.getBeanList(ConMgr.getConnection(), sql, CompDetail.class));
			
			lastLineNo = compPres.getCompDetail().size();
			for (int i=0; i<compPres.getCompDetail().size(); i++)
			{
				CompDetail compPresDet = (CompDetail) compPres.getCompDetail().get(i);

				try
				{
				
/*I.TIPO_INV,
I.ANIO,
I.CONSEC,
I.CODIGO_UE,
I.COMPANIA, 
I.MES*/

					iCta.put(compPresDet.getKey(), compPresDet);
					if(fg.trim().equals("CF"))vCta.add(compPresDet.getTipoInv()+"-"+compPresDet.getAnio()+"-"+compPresDet.getConsec()+"-"+compPresDet.getCodigoUe()+"-"+compPresDet.getCompania()+"-"+compPresDet.getMes());
					else if(fg.trim().equals("AC")) vCta.add(compPresDet.getAnioCfi()+"-"+compPresDet.getTipoCom()+"-"+compPresDet.getNumDoc()+"-"+compPresDet.getAnio()+"-"+compPresDet.getTipoInv()+"-"+compPresDet.getCompania()+"-"+compPresDet.getCodigoUe()+"-"+compPresDet.getConsec()+"-"+compPresDet.getMes());
					
					/*C.ANIO_CFI, 
 C.TIPO_COM, 
 C.NUM_DOC, 
   C.ANIO, 
   C.TIPO_INV, 
   C.COMPANIA, 
   C.CODIGO_UE, 
   C.CONSEC, 
   C.MES,*/
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="<%=fgLabel%> - "+document.title;

function doSubmit(baction)
{
	document.form1.baction.value = baction;
	window.frames['itemFrame'].doSubmit();
}
function printPres(){
   //abrir_ventana("../presupuesto/print_presupuesto_ope.jsp?anio=<%=anio%>");
}
function selCompromiso(){
var anio = document.form1.anio.value;
   abrir_ventana('../presupuesto/sel_compromisos.jsp?fg=<%=fg%>&anio='+anio);
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=fgLabel.toUpperCase()%>"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+ compPres.getCompDetail().size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("usuario",""+compPres.getUsuario())%>
<%=fb.hidden("fechaSistema",""+compPres.getFechaSistema())%>
<%=fb.hidden("montoAnterior",""+compPres.getMontoAnterior())%>
<%=fb.hidden("fechaMod",""+compPres.getFechaMod())%>
<%=fb.hidden("usuarioMod",""+compPres.getUsuarioMod())%>

<tr>
	<td class="TableBorder">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader01">
			<td colspan="6"><%=fgLabel.toUpperCase()%></td>
		</tr>
		<%if(fg.trim().equals("CF")){%>
		<tr class="TextRow01">
			<td  width="10%"><cellbytelabel>Tipo Compromiso</cellbytelabel></td>
			<td  width="20%"><%//=fb.textBox("compania",pres.getCompania(),true,false,viewMode,10)%> 
							<%//=fb.textBox("descCompania",pres.getDescCompania(),true,false,viewMode,40)%>
							<%=fb.select(ConMgr.getConnection(), "select tipo_com, descripcion from tbl_com_tipo_compromiso", "tipoCom",compPres.getTipoCom(),false,viewMode, 0, "text10", "", "")%>
							<%//=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:selCuenta()\"")%></td>
			<td width="15%"><cellbytelabel>N&uacute;mero Doc</cellbytelabel>:</td>
			<td width="15%"><%=fb.textBox("anio",compPres.getAnio(),true,false,viewMode,10)%>
							<%=fb.textBox("numDoc",compPres.getNumDoc(),false,false,(fg.trim().equals("CF"))?true:viewMode,10)%>
			<td width="15%"><cellbytelabel>Mes</cellbytelabel></td>
			<td width="25%"><%=fb.textBox("mes",compPres.getMes(),true,false,viewMode,10)%></td>
		</tr>
		<%}else{%>
		<tr class="TextRow01">
			<td  width="10%"><cellbytelabel>A&ntilde;o Del Ajuste</cellbytelabel></td>
			<td  width="20%"><%=fb.textBox("anio",compPres.getAnio(),true,false,viewMode,10)%><%//=fb.textBox("compania",pres.getCompania(),true,false,viewMode,10)%> 
							<%//=fb.textBox("descCompania",pres.getDescCompania(),true,false,viewMode,40)%>
							<%//=fb.select(ConMgr.getConnection(), "select tipo_com, descripcion from tbl_com_tipo_compromiso", "tipoCom",compPres.getTipoCom(),false,viewMode, 0, "text10", "", "")%>
							<%//=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:selCuenta()\"")%></td>
			<td width="15%"><cellbytelabel>N&uacute;mero Del Ajuste</cellbytelabel>:</td>
			<td width="15%"><%=fb.textBox("numDoc",compPres.getNumDoc(),false,false,true,10)%>
			<td width="15%">Mes</td>
			<td width="25%"><%=fb.textBox("mes",compPres.getMes(),true,false,viewMode,10)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Comp. Referencia</cellbytelabel></td>
			<td colspan="5"><%=fb.textBox("anioRef",compPres.getAnioRef(),false,false,true,10)%>
				<%=fb.textBox("tipoComRef",compPres.getTipoComRef(),false,false,true,10)%>
				<%=fb.textBox("numDocRef",compPres.getNumDocRef(),false,false,true,10)%>
				<%=fb.textBox("descTipoComRef",compPres.getDescTipoComRef(),false,false,true,25)%>
				<%=fb.button("buscar","...",false,viewMode,"","","onClick=\"javascript:selCompromiso()\"")%></td>
		</tr>
		<%}%>
		
		<tr class="TextRow02">
			<td><cellbytelabel>Fecha Documento</cellbytelabel></td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fechaDocumento" />
				<jsp:param name="valueOfTBox1" value="<%=compPres.getFechaDocumento()%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include></td>
			<td><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("estado",(fg.trim().equals("CF"))?"COM=COMPROMETIDO,PAG=PAGADO,ANU=ANULADO":"DB=DEBITO,CR=CREDITO,AN=ANULADO",compPres.getEstado(),false,viewMode,0,null,null,null,"","")%></td>
			<td>
			   <cellbytelabel>Monto</cellbytelabel> <%//=(fg.trim().equals("CF"))?" Total:":" Ajustar:"%>
			   <%if(fg.trim().equals("CF")){%> <cellbytelabel>Total</cellbytelabel>
			   	<%}else{%>
			   		 <cellbytelabel>Ajustar</cellbytelabel>
			   	<%}%>
			</td>
			<td><%=fb.decBox("monto",compPres.getMonto(),true,false,viewMode,10,null,null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Justificaci&oacute;n</cellbytelabel></td>
			<td colspan="3"><%=fb.textarea("explicacion",compPres.getExplicacion(),false,false,viewMode,50,5,2000)%></td>
			<td>
			   <%=(fg.trim().equals("CF"))?"Comprometido:":"Total del Ajuste:"%>
			   <%if(fg.trim().equals("CF")){%> <cellbytelabel>Comprometido</cellbytelabel>
			   	<%}else{%>
			   		 <cellbytelabel>Total del Ajuste</cellbytelabel>
			   	<%}%>
			</td>
			<td><%=fb.decBox("total","0",true,false,true,10,null,null,"")%></td>
		</tr>
		
		<tr>
			<td colspan="6">
				<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../presupuesto/reg_compromisos_pres_det.jsp?mode=<%=mode%>&fg=<%=fg%>&lastLineNo=<%=lastLineNo%>"></iframe><!---->
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
		CompMgr.setErrCode(request.getParameter("errCode"));
		CompMgr.setErrMsg(request.getParameter("errMsg"));
	}
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/list_compromisos.jsp"))
	{
%>
  window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/list_compromisos.jsp")%>&fg=<%=fg%>';
<%
	}
	else
	{
%>
  window.opener.location = '<%=request.getContextPath()%>/presupuesto/list_compromisos.jsp?fg=<%=fg%>';
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
} else throw new Exception(CompMgr.getErrMsg());
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