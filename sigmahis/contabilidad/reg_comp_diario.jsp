<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.Comprobante"%>
<%@ page import="issi.contabilidad.CompDetails"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CompMgr" scope="page" class="issi.contabilidad.ComprobanteMgr" />
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCta" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
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
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Comprobante CompDet = new Comprobante();
CommonDataObject cdoH = new CommonDataObject();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");

String change = request.getParameter("change");
String anio = request.getParameter("anio");
String no = request.getParameter("no");
String tipo = request.getParameter("tipo");
String regType = request.getParameter("regType");
String usadoPor = request.getParameter("usado_por");
boolean viewMode = false;
int lastLineNo = 0;
StringBuffer sbSql = new StringBuffer();

if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;
if (tipo == null) tipo = "1";
if (regType == null) regType = "D";
if (usadoPor == null) usadoPor = "";

if (fg == null) throw new Exception("El Tipo de Comprobante no es válido. Por favor intente nuevamente!");
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
	
	
	if (change == null)
	{
		iCta.clear();
		vCta.clear();
			if (mode.equalsIgnoreCase("add")&&!fg.trim().equals("PLA"))
			{
				String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
				CompDet.setConsecutivo("0");
				CompDet.setFechaCreacion(cDate);
				CompDet.setFechaSistema(cDate);
				CompDet.setFg(fg);
				CompDet.setCreadoPor("REGISTRADO MANUAL");
				CompDet.setUsuarioCreacion((String) session.getAttribute("_userName"));
				CompDet.setRegType(regType);
				//CompDet.setFg(fg);
				if(regType.trim().equals("H")){
					sql = "select ano, 13 mes from tbl_con_estado_anos where cod_cia=" + (String) session.getAttribute("_companyId") + " and estado_hist='ACT'";
					cdoH = SQLMgr.getData(sql);
					//if(cdoH == null){sql = "select ano-1 ano, 13 mes from tbl_con_estado_anos where cod_cia=" + (String) session.getAttribute("_companyId") + " and estado='ACT'";
					//cdoH = SQLMgr.getData(sql);}
				if(cdoH == null){	
					
					//CompDet.setEaAno(cdoH.getColValue("ano"));
					//CompDet.setMes(cdoH.getColValue("mes"));
					CompDet.setEaAno("");
					CompDet.setMes("");
				}else {CompDet.setEaAno(cdoH.getColValue("ano"));
					CompDet.setMes(cdoH.getColValue("mes"));}
			  }
			}
			else 
			{
				String tableName = "";
				if(fg.equals("CD")) tableName = "tbl_con_encab_comprob";
				else if(fg.equals("PLA")) tableName = " tbl_pla_pre_encab_comprob ";
				
				sql = "select ea_ano eaano,";
				if(fg.equals("PLA"))sql += " consecutivo_comp ";
				else sql += " consecutivo ";
				sql += " as consecutivo, compania, mes, decode('"+fg+"','PLA',26,clase_comprob)as claseComprob, descripcion, total_cr totalCr, total_db totalDb, n_doc nDoc, status, to_char(fecha_comp,'dd/mm/yyyy') fechacomp, comp_resum compresum, to_char(nvl(fecha_creacion,fecha_comp),'dd/mm/yyyy') fechacreacion,to_char(nvl(fecha_sistema,sysdate),'dd/mm/yyyy') fechaSistema,nvl(decode(creado_por,'SP','PROCESO AUTOMATICO','RCM','REGISTRADO MANUAL','RP','REGISTROS DE PLANILLA','ORIGEN DESCONOCIDO') ,'')creadoPor,modificado_por as modificadoPor,creado_por as creadoDesde,nvl(usuario_creacion,usuario) as usuarioCreacion,usuario_modificacion as usuarioModificacion ,estado ";
				if(!fg.trim().equals("PLA")){sql +=",reg_type as regType ";}
				sql +="  from "+tableName+" where compania = " + (String) session.getAttribute("_companyId") + " and ea_ano = " + anio;
				if(!fg.trim().equals("PLA")) sql += " and consecutivo = " + no;
				else sql += " and consecutivo_comp = " + no;

				if(!fg.trim().equals("PLA")){sql +=" and tipo = " + tipo;sql +=" and reg_type = '"+regType+"'";}

			System.out.println("Encab=\n"+sql);
			CompDet = (Comprobante) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Comprobante.class);
			//CompDet.setModificadoPor(""+(String) session.getAttribute("_userName"));
			if(fg.equals("CD")) tableName = "tbl_con_detalle_comprob";
			else if(fg.equals("PLA")) tableName = "tbl_pla_pre_detalle_comprob ";

			sql = "select det.ano, det.consecutivo, det.compania, det.renglon, det.ano_cta anocta, det.cta1, det.cta2, det.cta3, det.cta4, det.cta5, det.cta6, det.tipo_mov tipomov, det.valor,det.comentario||decode(det.ref_id,'-',' ',' - '||(det.ref_id ||' - '||det.ref_desc ))as comentario, det.ref_type as refType, det.ref_id as refId, det.ref_desc as refDesc,decode('"+fg+"','PLA','I','U') action,nvl((select cg.descripcion from tbl_con_catalogo_gral cg  where cg.cta1=det.cta1 and cg.cta2 =det.cta2 and cg.cta3 =det.cta3 and cg.cta4 =det.cta4 and cg.cta5=det.cta5 and cg.cta6=det.cta6 and cg.compania=det.compania ),'-') as descCuenta,nvl((select num_cuenta from tbl_con_catalogo_gral cg where cg.cta1=det.cta1 and cg.cta2 =det.cta2 and cg.cta3 =det.cta3 and cg.cta4 =det.cta4 and cg.cta5=det.cta5 and cg.cta6=det.cta6 and cg.compania=det.compania ),det.cta1||'.'||det.cta2||'.'||det.cta3||'.'||det.cta4||'.'||det.cta5||'.'||det.cta6) as cuenta,'"+CompDet.getCreadoDesde()+"' creadoPor";
			if(!fg.equals("PLA"))sql += ",nvl((select count(*) from tbl_con_registros_auxiliar aux where aux.trans_id =det.consecutivo and aux.trans_anio=det.ano and aux.compania = det.compania and aux.trans_renglon=det.renglon and aux.trans_tipo=det.tipo),0)";
			else sql += ", 0 ";
			sql += " detalleAux from "+tableName+" det where det.ano="+anio+" and det.consecutivo="+no+" and det.compania="+(String) session.getAttribute("_companyId");
			if(!fg.trim().equals("PLA")){sql +=" and det.tipo = " + tipo;sql +=" and det.reg_type = '"+regType+"'";}
			sql = "select lpad(rownum,4,'0') as key, z.* from ("+sql+" order by det.renglon/*tipo_mov desc*/) z";

			System.out.println("Det=\n"+sql);
			CompDet.setCompDetail(sbb.getBeanList(ConMgr.getConnection(), sql, CompDetails.class));

			//if()CompDet.setFechaSistema(CmnMgr.getCurrentDate("dd/mm/yyyy"));
			lastLineNo = CompDet.getCompDetail().size();
			for (int i=0; i<CompDet.getCompDetail().size(); i++)
			{
				CompDetails cta = (CompDetails) CompDet.getCompDetail().get(i);

				try
				{
					iCta.put(cta.getKey(), cta);
					vCta.add(cta.getCta1()+"-"+cta.getCta2()+"-"+cta.getCta3()+"-"+cta.getCta4()+"-"+cta.getCta5()+"-"+cta.getCta6());
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
document.title="Comprobante <%=(fg.equals("CD")&&!regType.trim().equals("H"))?"Diario":"Histórico"%> - "+document.title;
function doSubmit(baction){document.form1.baction.value = baction;window.frames['itemFrame'].doSubmit();}
function checkAnio(obj){var reg_type = document.form1.reg_type.value;if(reg_type=='D'){if(obj.value !=''){	if(!hasDBData('<%=request.getContextPath()%>','tbl_con_estado_anos','ano='+obj.value+' and cod_cia=<%=(String) session.getAttribute("_companyId")%> and estado=\'ACT\'','')){CBMSG.warning('Este año no existe o no está Activo!');obj.value='';obj.focus();}}else CBMSG.warning('Valor de año invalido!!');} setDate();}
function checkMes(obj){
var anio = document.form1.ea_anio.value;
if(anio!=''){
var reg_type = document.form1.reg_type.value;
if(reg_type=='D'){if(obj.value !=''){	if(!hasDBData('<%=request.getContextPath()%>','tbl_con_estado_meses','mes='+obj.value+' and ano ='+anio+'and cod_cia=<%=(String) session.getAttribute("_companyId")%> and estatus<>\'CER\'','')){CBMSG.warning('El mes no existe o no está Activo!');obj.value='';obj.focus();}}else CBMSG.warning('Valor de mes invalido!!');
}}else CBMSG.warning('Introduzca el Año'); setDate();}

function setDate()
{
	anio=document.getElementById("ea_anio").value;
	mes=document.getElementById("mes").value;
	fecha=document.getElementById("fecha");
	if(anio!='' && mes!='') fecha.value='01/'+mes+'/'+anio;
}
function printComprob(tipoRep){ 
var anio = document.form1.ea_anio.value;
var id=document.form1.consecutivo.value;
var regType = document.form1.reg_type.value;
var tipo = document.form1.tipo.value;

if('<%=mode%>'!='add')
{

	if(tipoRep=='DET')abrir_ventana('../contabilidad/print_list_comprobante_mensual.jsp?fp=listComp&anio='+anio+'&no='+id+'&tipo='+tipo+'&fg=<%=fg%>&regType='+regType);
	else if(tipoRep=='RES')
	{	
		if('<%=fg%>'=='PLA')CBMSG.warning('Opcion invalida para Comprobantes de Planilla!');
		else abrir_ventana('../contabilidad/print_comprob_resumido.jsp?fp=listComp&anio='+anio+'&no='+id+'&tipo='+tipo+'&fg=<%=fg%>&regType='+regType);
	}
}else CBMSG.warning('Para imprimir el reporte el comprobante tiene que ser Guardado!');

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - REGISTRO DE COMPROBANTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+iCta.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("tipo",""+tipo)%>
<%=fb.hidden("estado",""+CompDet.getEstado())%>
<%=fb.hidden("usado_por",usadoPor)%>
<tr>
	<td class="TableBorder">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow02">
			<td colspan="10">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Tipo Comprobante</td>
			<td colspan="9">
			<%=fb.select("reg_type",(regType.equals("H"))?"H=HISTORICO":"D=DIARIO",CompDet.getRegType(),true,false,false,0)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">A&ntilde;o</td>
			<td><%=fb.intBox("ea_anio",CompDet.getEaAno(),true,false,(viewMode || mode.trim().equals("edit") || (fg.equals("CH")||regType.equals("H"))||fg.trim().equals("PLA")),5,null,null,"onBlur=\"javascript:checkAnio(this)\"")%></td>
			<td align="right">Mes</td>
			<td><%=fb.intBox("mes",CompDet.getMes(),true,false,(viewMode||mode.trim().equals("edit")||(fg.equals("CH")||regType.equals("H"))||fg.trim().equals("PLA")),5,null,null,"onBlur=\"javascript:checkMes(this)\"")%></td>
			<td align="right">Consecutivo</td>
			<td><%=fb.intBox("consecutivo",CompDet.getConsecutivo(),false,false,true,5)%></td>
			<td align="right">Fecha Creaci&oacute;n</td>
			<td>
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="nameOfTBox1" value="fecha" />
          <jsp:param name="valueOfTBox1" value="<%=CompDet.getFechaCreacion()%>" />
          <jsp:param name="fieldClass" value="text10" />
          <jsp:param name="buttonClass" value="text10" />
		  <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>" />
          </jsp:include>
			<%//=fb.textBox("fecha",CompDet.getFechaCreacion(),false,false,(viewMode || mode.trim().equals("edit")),10)%></td>
			<td align="right">Fecha Sistema</td>
			<td><%=fb.textBox("fechaSistema",CompDet.getFechaSistema(),false,false,true,10)%></td>	
		</tr>
		<tr class="TextRow01">
			<td align="right">Clase</td>
			<td colspan="7">
			<%
			sbSql = new StringBuffer();
			
			sbSql.append(" select codigo_comprob, descripcion from tbl_con_clases_comprob where estado='A' ");
			
			if(mode.trim().equals("add")&&!fg.trim().equals("PLA")){sbSql.append(" and usado_por='U' ");}
			else if(mode.trim().equals("edit")||fg.trim().equals("PLA")){sbSql.append("and codigo_comprob=");
			sbSql.append(CompDet.getClaseComprob());}
			 sbSql.append(" and tipo ='C'");
			
			
			%>
			
			<%=fb.select(ConMgr.getConnection(), sbSql.toString(), "clase_comprob", CompDet.getClaseComprob(), false, viewMode, 0, "text10", "", "")%></td>
			<td align="right">Estado</td>
			<td><%=fb.select("status","PE=PENDIENTE"+((viewMode)?",AP=APROBADO,DE=DESAPROBADO":""),CompDet.getStatus(),false,viewMode,0,"","","")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Descripci&oacute;n</td>
			<td colspan="7"><%=fb.textBox("descripcion",CompDet.getDescripcion(),true,false,viewMode,70)%></td>
			<td>&nbsp;</td>
			<td><%=((viewMode)?fb.select("estadoDesc","A=APROBADO,I=ANULADO",CompDet.getEstado(),false,true,0,"","",""):"")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="6">&nbsp;</td>
			<td align="right">D&eacute;bito</td>
			<td><%=fb.decBox("sumDebito","0",false,false,true,10)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Doc. Fuente</td>
			<td><%=fb.textBox("n_doc",CompDet.getNDoc(),false,false,viewMode,10)%></td>
			<td colspan="6">&nbsp;</td>
			<td align="right">Cr&eacute;dito</td>
			<td><%=fb.decBox("sumCredito","0",false,false,true,10)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Creado:</td>
			<td colspan="3"><%=fb.textBox("creadoPor",CompDet.getCreadoPor(),false,false,true,30)%>Por:<%=CompDet.getUsuarioCreacion()%></td>
			<td colspan="2">&nbsp;</td>
			<td align="right">Modificado Por</td>
			<td  colspan="3"><%=fb.textBox("modificadoPor",CompDet.getModificadoPor(),false,false,true,20)%>
			<%=(!mode.trim().equals("add"))?fb.button("repDeta","IMPRIMIR DET.",true,false,null,null,"onClick=\"javascript:printComprob('DET')\"","Reporte Detallado"):""%>
			<%=(!fg.trim().equals("PLA")&&!mode.trim().equals("add"))?fb.button("repRes","IMPRIMIR RES.",true,false,null,null,"onClick=\"javascript:printComprob('RES')\"","Reporte Resumido"):""%>
			
			</td>
		</tr>
		<tr>
			<td colspan="10">
				<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../contabilidad/reg_comp_diario_det.jsp?mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&lastLineNo=<%=lastLineNo%>&usado_por=<%=usadoPor%>"></iframe>
			</td>					
		</tr>		
		<tr class="TextRow01">
			<td colspan="8" align="right">Totales del Detalle</td>
			<td align="right">DB <%=fb.decBox("totalDb",CompDet.getTotalDb(),false,false,true,10,null,null,"")%></td>
			<td align="right">CR <%=fb.decBox("totalCr",CompDet.getTotalCr(),false,false,true,10,null,null,"")%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="10" align="right">
				Opciones de Guardar: 
				<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro 
				<!--<%=fb.radio("saveOption","O")%>Mantener Abierto -->
				<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar 
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
 if(!fp.trim().equals("AP")){
 if(session.getAttribute("_urlInfo")!= null &&((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/list_mg_comp_diario.jsp")){%>
  window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/list_mg_comp_diario.jsp")%>&fp=<%=fp%>';
<%}else{%>
  window.opener.location = '<%=request.getContextPath()%>/contabilidad/list_mg_comp_diario.jsp?fg=<%=fg%>&fp=<%=fp%>';
<%}}else{
  if(session.getAttribute("_urlInfo")!= null &&((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/list_mg_aprob_comp.jsp")){%>
  window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/list_mg_aprob_comp.jsp")%>&fp=<%=fp%>';
<%}else{%>
  window.opener.location = '<%=request.getContextPath()%>/contabilidad/list_mg_aprob_comp.jsp?fg=<%=fg%>&fp=<%=fp%>';

<%}}%>
 
<%
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
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=fg%>&fp=<%=fp%>&tipo=<%=tipo%>&regType=<%=regType%>';
}

function editMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&fg=<%=fg%>&fp=<%=fp%>&tipo=<%=tipo%>&regType=<%=regType%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>