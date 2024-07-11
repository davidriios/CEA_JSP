<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.presupuesto.Presupuesto"%>
<%@ page import="issi.presupuesto.PresDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Vector" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iCta" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCta" scope="session" class="java.util.Vector"/>
<jsp:useBean id="PresMgr" scope="page" class="issi.presupuesto.PresupuestoMgr"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
PresMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Presupuesto pres = new Presupuesto();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");

String change = request.getParameter("change");
String anio = request.getParameter("anio");
String unidad = request.getParameter("unidad");
String tipoInv = request.getParameter("tipoInv");
String compania = request.getParameter("compania");
String consec = request.getParameter("consec");

boolean viewMode = false;
int lastLineNo = 0;
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;
if(anio ==null)anio=""+(Integer.parseInt(cDateTime.substring(6, 10))+1);
if(compania ==null)compania=(String) session.getAttribute("_companyId");
if (consec == null) consec = "";
if ( unidad == null ) unidad = "";

if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

String filter = "";
if (!viewMode)
{
	if (UserDet.getUserProfile().contains("0"))filter = " and not exists (select unidad from tbl_con_pres_fusion where compania = a.compania and unidad = a.codigo)";
	else{ 	filter +=" and a.codigo in(";
			if(session.getAttribute("_ua")!=null) filter += CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")); 
			else filter +="-1";
			filter +=")";
	}
}

/*  se omite el join  **filter**  para manejar por el parametro NIVEL_UNIDAD_PRESUPUESTO que solo se maneje por nivel  */

sql = "select a.codigo as optValueColumn, a.codigo||'-'||a.descripcion as optLabelColumn, a.codigo as optTitleColumn from tbl_sec_unidad_ejec a where a.compania = "+session.getAttribute("_companyId")+ /* filter+  */" and a.nivel in (select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'NIVEL_UNIDAD_PRESUPUESTO') from dual),',') from dual  )) /* and a.codigo < 100 */order by 2";
ArrayList alUE = sbb.getBeanList(ConMgr.getConnection(),sql,CommonDataObject.class);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change == null)
	{
			iCta.clear();
			vCta.clear();

			if (mode.equalsIgnoreCase("add"))
			{
				consec ="0";
				pres.setAnio(anio);
				pres.setConsec(consec);
				pres.setFechaCreacion(cDateTime);
				pres.setFechaModificacion(cDateTime);
				pres.setUsuarioCreacion((String) session.getAttribute("_userName"));
				pres.setUsuarioModificacion((String) session.getAttribute("_userName"));
				pres.setEstado("B");
				pres.setTipoEntrada("N");

				//pres.setFg(fg);
				pres.setUnidad(unidad);

				sql="SELECT lpad(rownum,3,'0')key , lpad(column_value,2,'0') mes FROM TABLE(SPLIT('1,2,3,4,5,6,7,8,9,10,11,12', ','))";
				pres.setPresDetail(sbb.getBeanList(ConMgr.getConnection(), sql, PresDetail.class));

			lastLineNo = pres.getPresDetail().size();
			for (int i=0; i<pres.getPresDetail().size(); i++)
			{
				PresDetail presDet = (PresDetail) pres.getPresDetail().get(i);

				try
				{
					iCta.put(presDet.getKey(), presDet);
					vCta.add(presDet.getMes());
				}
				catch (Exception e)
				{
					System.out.println("Unable to addget cta "+key);
				}
			}
			}
			else
			{

		sql = "select  a.anio, a.compania,a.tipo_inv tipoInv,a.descripcion,a.comentario,a.consec,a.categoria,a.cantidad,a.prioridad,a.tipo_entrada tipoEntrada,a.destino_final_bienactual destinoFinalBienactual,a.solicitado,a.precio_cot_unt precioCotUnt,a.observaciones,a.codigo_proveedor  codigoProveedor,(select nombre_proveedor from tbl_com_proveedor where compania= a.compania and cod_provedor = a.codigo_proveedor)descProveedor, a.codigo_ue unidad, a.preaprobado,to_char(a.preaprobado_fecha,'dd/mm/yyyy') preaprobadoFecha, a.preaprobado_usuario preaprobadoUsuario, a.usuario_creacion usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion, a.usuario_modificacion usuarioModificacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fechaModificacion, a.estado, to_char(a.fecha_envio,'dd/mm/yyyy') fechaEnvio, to_char(a.fecha_rechazo,'dd/mm/yyyy') fechaRechazo,a.motivo_rechazo motivoRechazo,a.origen,a.vobo_estado voboEstado,a.vobo_usuario  voboUsuario, to_char(a.vobo_fecha,'dd/mm/yyyy') voboFecha,ue.descripcion descUnidad from tbl_con_ante_inversion_anual a,tbl_sec_unidad_ejec ue where anio = "+anio+" and a.consec ="+consec+"  and a.compania="+compania+" and  a.codigo_ue ="+unidad+" and a.tipo_inv ="+tipoInv+" and  a.codigo_ue = ue.codigo and a.compania = ue.compania";

			System.out.println("Encab pres =\n"+sql);
			pres = (Presupuesto) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Presupuesto.class);


			//sql = "select lpad(rownum,3,'0') as key,a.anio, a.cta1, a.cta2,a.cta3, a.cta4, a.cta5, a.cta6, a.compania, lpad(mes,2,'0')mes, a.asignacion, a.anterior, a.estado_aprob, a.fecha_aprob, a.usuario_aprob, a.unidad, a.compania_origen, a.preaprobado, a.preaprobado_fecha, a.preaprobado_usuario, a.usuario_creacion, a.fecha_creacion, a.usuario_modificacion, a.fecha_modificacion, a.estado, a.fecha_envio from tbl_con_ante_cuenta_mensual a where anio = "+anio+" and cta1 = '"+cta1+"' and cta2 = '"+cta2+"' and cta3 = '"+cta3+"' and cta4 = '"+cta4+"' and cta5 = '"+cta5+"' and cta6 = '"+cta6+"' and compania ="+compania+"  order by 10 asc";

		sql = " select lpad(rownum,3,'0') as key,lpad(a.column_value,2,'0') mes,b.anio,b.compania, b.asignacion, b.unidad, b.preaprobado, b.estado_apr estadoAprob, b.estado, b.descripcion,to_char(b.preaprobado_fecha,'dd/mm/yyyy')preaprobadoFecha, b.preaprobado_usuario preaprobadoUsuario, b.usuario_creacion usuarioCreacion,  b.aprobado_usuario usuarioAprob, to_char(b.aprobado_fecha,'dd/mm/yyyy')fechaAprob, b.aprobado,to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion, b.usuario_modificacion usuarioModificacion,  to_char(b.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fechaModificacion,to_char(b.fecha_envio,'dd/mm/yyyy') fechaEnvio,to_char(b.fecha_rechazo,'dd/mm/yyyy') fechaRechazo from  (SELECT lpad(column_value,2,'0') column_value FROM TABLE(SPLIT('1,2,3,4,5,6,7,8,9,10,11,12', ',')))a,(select a.anio, lpad(a.mes,2,'0') mes, a.monto_solicitado asignacion, a.estado_apr, a.codigo_ue unidad, a.preaprobado, a.preaprobado_fecha, a.preaprobado_usuario,a.aprobado_usuario ,a.usuario_creacion, a.fecha_creacion, a.usuario_modificacion, a.fecha_modificacion, a.estado, a.fecha_envio ,a.descripcion,a.aprobado , a.aprobado_fecha,a.fecha_rechazo,a.compania from tbl_con_ante_inversion_mensual a where  a.anio = "+anio+" and a.consec ="+consec+"  and a.compania="+compania+" and  a.codigo_ue ="+unidad+" and a.tipo_inv ="+tipoInv+" )b where a.column_value = b.mes(+) order by 2 asc";


			System.out.println("Det=\n"+sql);
			pres.setPresDetail(sbb.getBeanList(ConMgr.getConnection(), sql, PresDetail.class));

			lastLineNo = pres.getPresDetail().size();
			for (int i=0; i<pres.getPresDetail().size(); i++)
			{
				PresDetail presDet = (PresDetail) pres.getPresDetail().get(i);

				try
				{
					iCta.put(presDet.getKey(), presDet);
					vCta.add(presDet.getMes());
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
<script language="javascript">
document.title="PRESUPUESTO - "+document.title;

function doSubmit(baction)
{
	document.form1.baction.value = baction;
	if(baction =='Enviar')
	{
		if(confirm('Una vez que el presupuesto es ENVIADO no podrá efectuar modificaciones al mismo.  RECUERDE Guardar los cambios hechos antes de proseguir!!!. Seguro que desea ejecutarlo?'))
		{
			window.frames['itemFrame'].doSubmit();
		}
	}
	else{
	window.frames['itemFrame'].doSubmit();}
}
function selCuenta()
{
var unidad = document.form1.unidad.value;
abrir_ventana('../common/search_catalogo_gral.jsp?fp=presOp&unidad='+unidad);
}
function selUnidad()
{
abrir_ventana('../inventario/sel_unid_ejec.jsp?fg=PRESINV');
}
function selProveedor()
{
abrir_ventana('../common/search_proveedor.jsp?fp=presInv');
}


function checkAnio(obj)
{
	/*if(!hasDBData('<%=request.getContextPath()%>','tbl_con_estado_anos','ano='+obj.value+' and cod_cia=<%=(String) session.getAttribute("_companyId")%> and estado=\'ACT\'',''))
	{
		alert('Este año no existe o no está Activo!');
		obj.value='';
		obj.focus();
	}*/
}
function setDestino(value)
{
	if(value=='R')
	{
		document.form1.destinoFinal.readOnly=false;
		document.form1.destinoFinal.className='FormDataObjectEnabled';
		document.form1.destinoFinal.disabled=false;
	}
	else
	{
		document.form1.destinoFinal.value='';
		document.form1.destinoFinal.readOnly=true;
		document.form1.destinoFinal.className='FormDataObjectDisabled';
		document.form1.destinoFinal.disabled=true;
	}
}

function printPres(){
	 var formato = "V";
			if ( document.getElementById("formato").checked == true ){
				 formato = "H";
			}
			if (formato == 'V'){
					abrir_ventana("print_presupuesto_inv.jsp?anio=<%=anio%>&consec=<%=consec%>&compania=<%=compania%>&unidad=<%=unidad%>&tipoInv=<%=tipoInv%>");
			}else{
				 abrir_ventana("print_presupuesto_inv_h.jsp?anio=<%=anio%>&consec=<%=consec%>&compania=<%=compania%>&unidad=<%=unidad%>&tipoInv=<%=tipoInv%>");
	 }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PRESUPUESTO - REGISTRO DE PRESUPUESTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<% if (mode.equalsIgnoreCase("add")) fb.appendJsValidation("if(document.form1.unidad.value.trim()==''){alert('Por favor seleccione la Unidad');error++;}");%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if (document.form1.baction.value=='Guardar'&&document.form1.tipoInv.value=='') {alert('Por favor indique el TIPO DE INVERSION'); error++;}");%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+ pres.getPresDetail().size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("compania",pres.getCompania())%>
<%=fb.hidden("estado",pres.getEstado())%>
<%=fb.hidden("usuarioCreacion",pres.getUsuarioCreacion())%>
<%=fb.hidden("fechaCreacion",pres.getFechaCreacion())%>
<%=fb.hidden("estadoAprob",pres.getEstadoAprob())%>
<%=fb.hidden("fechaAprob",pres.getFechaAprob())%>
<%=fb.hidden("usuarioAprob",pres.getUsuarioAprob())%>
<%=fb.hidden("companiaOrigen",pres.getCompaniaOrigen())%>
<%=fb.hidden("preaprobado",pres.getPreaprobado())%>
<%=fb.hidden("preaprobadoFecha",pres.getPreaprobadoFecha())%>
<%=fb.hidden("preaprobadoUsuario",pres.getPreaprobadoUsuario())%>
<%=fb.hidden("fechaEnvio",pres.getFechaEnvio())%>
<%=fb.hidden("fechaRechazo",pres.getFechaRechazo())%>
<%=fb.hidden("motivoRechazo",pres.getMotivoRechazo())%>
<%=fb.hidden("origen",pres.getOrigen())%>
<%=fb.hidden("voboEstado",pres.getVoboEstado())%>
<%=fb.hidden("voboUsuario",pres.getVoboUsuario())%>
<%=fb.hidden("voboFecha",pres.getVoboFecha())%>
<tr>
	 <td class="TableBorder">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader01">
			<td colspan="6"><cellbytelabel>INVERSION ANUAL</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td width="5%"><cellbytelabel>Unidad</cellbytelabel>: </td>
			<td colspan="4">
				<% if (mode.equalsIgnoreCase("add")) { %>
				<%=fb.select("unidad",alUE,pres.getUnidad(),false,(!mode.equalsIgnoreCase("add")),0,null,null,null,null,"S")%>
				<% } else { %>
				<%=fb.select("unidad_display",alUE,pres.getUnidad(),false,(!mode.equalsIgnoreCase("add")),0,null,null,null,null,"S")%>
				<%=fb.hidden("unidad",pres.getUnidad())%>
				<% } %>
			</td>
			<td><cellbytelabel>A&ntilde;o</cellbytelabel>:&nbsp;<%=fb.textBox("anio",pres.getAnio(),true,false,(viewMode|| !mode.trim().equals("add")),6)%></td>

		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Tipo Inv</cellbytelabel>.</td>
			<td colspan="4"><% if (mode.equals("add")) {%><%=fb.select(ConMgr.getConnection(), "select a.tipo_inv, a.descripcion||' - '||a.compania||' - '||(select nombre from tbl_sec_compania where codigo =a.compania) from tbl_con_tipo_inversion a where a.compania = "+(String) session.getAttribute("_companyId")+" order by a.descripcion", "tipoInv",pres.getTipoInv(),false,viewMode, 0, "", "", "","","S")%><%} else {%><%=fb.hidden("tipoInv",pres.getTipoInv())%><%=fb.select(ConMgr.getConnection(), "select a.tipo_inv, a.descripcion||' - '||a.compania||' - '||(select nombre from tbl_sec_compania where codigo =a.compania) from tbl_con_tipo_inversion a where a.compania = "+(String) session.getAttribute("_companyId")+" order by a.descripcion", "tipoInvDsp",pres.getTipoInv(),false,true, 0, "", "", "")%><%}%></td>
			<td><cellbytelabel>Consecutivo</cellbytelabel>:&nbsp;<%=fb.textBox("consec",pres.getConsec(),false,false,true,5)%></td>
		</tr>
		<tr class="TextHeader02">
			<td colspan="3"><cellbytelabel>Justificaci&acute;n</cellbytelabel></td>
			<td colspan="3"><cellbytelabel>Descripci&acute;n</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3"><%=fb.textarea("descripcion",pres.getDescripcion(),true,false,viewMode,45,3,2000)%></td>
			<td colspan="3"><%=fb.textarea("comentario",pres.getComentario(),false,false,viewMode,40,3,2000)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Cantidad</cellbytelabel></td>
			<td><%=fb.textBox("cantidad",pres.getCantidad(),true,false,viewMode,10)%></td>
			<td align="right"><cellbytelabel>Proveedor</cellbytelabel></td>
			<td colspan="3"><%=fb.textBox("codigoProveedor",pres.getCodigoProveedor(),false,false,true,10)%>
				<%=fb.textBox("descProveedor",pres.getDescProveedor(),false,false,true,40)%>
				<%=fb.button("buscar","...",false,(viewMode),"","","onClick=\"javascript:selProveedor()\"")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Tipo de apoyo</cellbytelabel></td>
			<td><%=fb.select("categoria","1=GENERADOR DE INGRESO,2=SERVICIOS DE APOYO OPERATIVO,3=SERVICIOS DE APOYO ADM.",pres.getCategoria(),"")%></td>
			<td align="right">Prioridad de la Compra</td>
			<td colspan="3"><%=fb.select("prioridad","1=URGENTE,2=MUY NECESARIO,3=NECESARIO",pres.getPrioridad(),"")%></td>
		</tr>

		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Remplazo</cellbytelabel>?</td>
			<td width="10%"><%=fb.radio("tipoEntrada","R",(pres.getTipoEntrada()!=null && !pres.getTipoEntrada().trim().equals("") && pres.getTipoEntrada().trim().equals("R") ),viewMode,false,"","","onClick=\"javascript:setDestino(this.value)\"")%></td>
			<td  align="right" rowspan="2" align="right">Destino final del Actual</td>
			<td colspan="4" rowspan="2"><%=fb.textarea("destinoFinal",pres.getDestinoFinalBienactual(),false,false,(viewMode||(pres.getTipoEntrada()!=null && !pres.getTipoEntrada().trim().equals("") && pres.getTipoEntrada().trim().equals("N"))),50,3,2000)%></td>
		</tr>

		<tr class="TextRow01">
			<td><cellbytelabel>Nueva inversi&oacute;n</cellbytelabel></td>
			<td><%=fb.radio("tipoEntrada","N",(pres.getTipoEntrada()!=null && !pres.getTipoEntrada().trim().equals("") && pres.getTipoEntrada().trim().equals("N")),viewMode,false,"","","onClick=\"javascript:setDestino(this.value)\"")%></td>
		</tr>

		<tr class="TextRow01">
			<td><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
			<td colspan="4"><%=fb.textarea("observaciones",pres.getObservaciones(),false,false,viewMode,60,3,2000)%></td>
			<td><%=fb.button("print","Imprimir",false,false,"","height:40px","onClick=\"javascript:printPres()\"")%>
								 Horizontal?: <%=fb.checkbox("formato","")%>
			</td>
		</tr>
		<tr class="TextRow02">
			<td><cellbytelabel>Solicitado</cellbytelabel></td>
			<td><%=fb.decBox("solicitado",pres.getSolicitado(),true,false,true,10,null,null,"")%></td>
			<td><cellbytelabel>Precio Cotizado Unitario</cellbytelabel></td>
			<td><%=fb.decBox("precioCotUnt",pres.getPrecioCotUnt(),true,false,viewMode,10,null,null,"")%></td>
			<td align="right">Total Mto Solicitado:</td>
			<td><%=fb.decBox("totalSolicitado","",false,false,true,10,null,null,"")%></td>
		</tr>



		<tr>
			<td colspan="6">
				<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../presupuesto/reg_presupuesto_inv_det.jsp?mode=<%=mode%>&fg=<%=fg%>&lastLineNo=<%=lastLineNo%>"></iframe><!---->			</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Total Solicitado</cellbytelabel>:</td>
			<td align="center"><%=fb.decBox("totalSolicitado2","",false,false,true,10,null,null,"")%></td>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="6" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,viewMode)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,viewMode)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<authtype type='50'><%=fb.button("save","Enviar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%></authtype>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>			</td>
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
		PresMgr.setErrCode(request.getParameter("errCode"));
		PresMgr.setErrMsg(request.getParameter("errMsg"));
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<% if (PresMgr.getErrCode().equals("1")) { %>
alert('<%=PresMgr.getErrMsg()%>');
	<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/list_presupuesto_inv.jsp")) { %>
window.opener.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/list_presupuesto_inv.jsp")%>&fg=<%=fg%>';
	<% } else { %>
window.opener.location='<%=request.getContextPath()%>/presupuesto/list_presupuesto_inv.jsp?fg=<%=fg%>&anio=<%=anio%>';
	<% } %>
	<% if (saveOption.equalsIgnoreCase("N")) { %>
setTimeout('addMode()',500);
	<% } else if (saveOption.equalsIgnoreCase("O")) { %>
setTimeout('editMode()',500);
	<% } else if (saveOption.equalsIgnoreCase("C")) { %>
window.close();
	<% } %>
<% } else throw new Exception(PresMgr.getErrMsg()); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&unidad=<%=unidad%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&fg=<%=fg%>&anio=<%=anio%>&consec=<%=consec%>&compania=<%=compania%>&unidad=<%=unidad%>&tipoInv=<%=tipoInv%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>