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
fg= PO  --->  Registro de ante proyecto del Presupuesto Operativo
fg= UPO --->  Actualizacion del Presupuesto Operativo( Monto Consumido)
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
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta5 = request.getParameter("cta5");
String cta6 = request.getParameter("cta6");
String compania = request.getParameter("compania");
String unidad = request.getParameter("unidad");

boolean viewMode = false;
int lastLineNo = 0;
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;
if(anio ==null)anio=""+(Integer.parseInt(cDateTime.substring(6, 10))+1);
if(compania ==null)compania=(String) session.getAttribute("_companyId");
if(fg ==null)fg="PO";

if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

String filter = "";
if (!viewMode)
{
	if (UserDet.getUserProfile().contains("0")) filter = " and not exists (select unidad from tbl_con_pres_fusion where compania = a.compania and unidad = a.codigo)";
	else{ 	filter +=" and a.codigo in(";
			if(session.getAttribute("_ua")!=null) filter += CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")); 
			else filter +="-1";
			filter +=")";
	}
}

/*  se omite el join  **filter**  para manejar por el parametro NIVEL_UNIDAD_PRESUPUESTO que solo se maneje por nivel  */


sql = "select a.codigo as optValueColumn, a.codigo||'-'||a.descripcion as optLabelColumn, a.codigo as optTitleColumn from tbl_sec_unidad_ejec a where a.compania = "+session.getAttribute("_companyId")+  /*  filter+   */" and a.nivel in (select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'NIVEL_UNIDAD_PRESUPUESTO') from dual),',') from dual  )) order by 2";
/*  and a.codigo < 100  */
ArrayList alUE = sbb.getBeanList(ConMgr.getConnection(),sql,CommonDataObject.class);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change == null)
	{
			iCta.clear();
			vCta.clear();

			if (mode.equalsIgnoreCase("add"))
			{

				pres.setAnio(anio);
				pres.setFechaCreacion(cDateTime);
				pres.setFechaModificacion(cDateTime);
				pres.setUsuarioCreacion((String) session.getAttribute("_userName"));
				pres.setUsuarioModificacion((String) session.getAttribute("_userName"));
				pres.setEstado("B");
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

		if(fg.trim().equals("PO"))
		{
		sql = "select  a.anio, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5,a.cta6, a.compania, nvl(a.asignacion_actual,0) asignacionActual, nvl(a.asignacion_anterior,0) asignacionAnterior, nvl(a.ejecutado_dic,0) ejecutadoDic, a.justificacion, a.ejecutado, a.estado_aprob estadoAprob, to_char(a.fecha_aprob,'dd/mm/yyyy') fechaAprob, a.usuario_aprob usuarioAprob, a.unidad, a.compania_origen companiaOrigen, a.preaprobado, to_char(a.preaprobado_fecha,'dd/mm/yyyy') preaprobadoFecha, a.preaprobado_usuario preaprobadoUsuario, a.usuario_creacion usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion, a.usuario_modificacion usuarioModificacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fechaModificacion, a.estado, to_char(a.fecha_envio,'dd/mm/yyyy') fechaEnvio, to_char(a.fecha_rechazo,'dd/mm/yyyy') fechaRechazo,cg.descripcion descCuenta ,ue.descripcion descUnidad,(select descripcion from tbl_con_cla_ctas  where codigo_clase = cg.tipo_Cuenta )descTipoCta from tbl_con_ante_cuenta_anual a,tbl_con_catalogo_gral cg ,tbl_sec_unidad_ejec ue where anio = "+anio+" and a.cta1 ='"+cta1+"' and a.cta2 ='"+cta2+"' and a.cta3 ='"+cta3+"' and a.cta4 ='"+cta4+"' and a.cta5 ='"+cta5+"' and a.cta6 ='"+cta6+"' and a.compania="+compania+" and a.unidad="+unidad+" and a.cta1 =cg.cta1 and a.cta2 =cg.cta2 and a.cta3 =cg.cta3 and a.cta4 =cg.cta4 and a.cta5 =cg.cta5 and a.cta6 =cg.cta6 and a.compania_origen =cg.compania and a.unidad = ue.codigo and a.compania = ue.compania";
		}
		else if(fg.trim().equals("UPO"))
		{
			sql = "select a.anio, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5,a.cta6, a.compania, nvl(a.asignacion,0) asignacionActual, a.unidad, a.compania_origen companiaOrigen,a.preaprobado, to_char(a.preaprobado_fecha,'dd/mm/yyyy') preaprobadoFecha, a.preaprobado_usuario preaprobadoUsuario,a.consumido,cg.descripcion descCuenta ,ue.descripcion descUnidad,(select descripcion from tbl_con_cla_ctas  where codigo_clase = cg.tipo_Cuenta )descTipoCta, a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 cuenta from tbl_con_cuenta_anual a,tbl_con_catalogo_gral cg ,tbl_sec_unidad_ejec ue where anio = "+anio+" and a.cta1 ='"+cta1+"' and a.cta2 ='"+cta2+"' and a.cta3 ='"+cta3+"' and a.cta4 ='"+cta4+"' and a.cta5 ='"+cta5+"' and a.cta6 ='"+cta6+"' and a.compania="+compania+" and a.unidad="+unidad+" and a.cta1 =cg.cta1 and a.cta2 =cg.cta2 and a.cta3 =cg.cta3 and a.cta4 =cg.cta4 and a.cta5 =cg.cta5 and a.cta6 =cg.cta6 and a.compania_origen =cg.compania and a.unidad = ue.codigo and a.compania = ue.compania order by a.anio desc,a.unidad asc";


		}
			System.out.println("Encab pres =\n"+sql);
			pres = (Presupuesto) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Presupuesto.class);


	if(fg.trim().equals("PO"))
	{
	sql = " select lpad(rownum,3,'0') as key,lpad(a.column_value,2,'0') mes,b.anio, b.cta1, b.cta2,b.cta3, b.cta4, b.cta5, b.cta6, b.compania, b.asignacion, b.anterior, b.estado_aprob estadoAprob, to_char(b.fecha_aprob,'dd/mm/yyyy')fechaAprob, b.usuario_aprob usuarioAprob , b.unidad, b.compania_origen companiaOrigen, b.preaprobado, to_char(b.preaprobado_fecha,'dd/mm/yyyy')preaprobadoFecha, b.preaprobado_usuario preaprobadoUsuario, b.usuario_creacion usuarioCreacion,  to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion, b.usuario_modificacion usuarioModificacion,  to_char(b.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fechaModificacion, b.estado,to_char(b.fecha_envio,'dd/mm/yyyy') fechaEnvio from  (SELECT lpad(column_value,2,'0')column_value FROM TABLE(SPLIT('1,2,3,4,5,6,7,8,9,10,11,12', ',')))a,(select a.anio, a.cta1, a.cta2,a.cta3, a.cta4, a.cta5, a.cta6, a.compania, lpad(a.mes,2,'0') mes, a.asignacion, a.anterior, a.estado_aprob, a.fecha_aprob, a.usuario_aprob, a.unidad, a.compania_origen, a.preaprobado, a.preaprobado_fecha, a.preaprobado_usuario, a.usuario_creacion, a.fecha_creacion, a.usuario_modificacion, a.fecha_modificacion, a.estado, a.fecha_envio from tbl_con_ante_cuenta_mensual a where  a.anio = "+anio+" and a.cta1 = '"+cta1+"' and a.cta2 = '"+cta2+"' and a.cta3 = '"+cta3+"' and a.cta4 = '"+cta4+"' and a.cta5 = '"+cta5+"' and a.cta6 = '"+cta6+"' and a.compania ="+compania+"and a.unidad="+unidad+"  )b where a.column_value = b.mes(+) order by 2 asc";
	}
	else if(fg.trim().equals("UPO"))
	{


		sql = " select lpad(rownum,3,'0') as key,lpad(a.column_value,2,'0') mes,b.anio, b.cta1, b.cta2,b.cta3, b.cta4, b.cta5, b.cta6, b.compania, b.asignacion,b.preaprobado, to_char(b.preaprobado_fecha,'dd/mm/yyyy')preaprobadoFecha, b.preaprobado_usuario preaprobadoUsuario,b.unidad, b.compania_origen companiaOrigen,b.usuario_modificacion usuarioModificacion,  to_char(b.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fechaModificacion, b.estado,b.traslado,b.redistribuciones,b.consumido  from  (SELECT lpad(column_value,2,'0')column_value FROM TABLE(SPLIT('1,2,3,4,5,6,7,8,9,10,11,12', ',')))a,(select a.anio, a.cta1, a.cta2,a.cta3, a.cta4, a.cta5, a.cta6, a.compania, lpad(a.mes,2,'0') mes, a.asignacion,a.unidad, a.compania_origen, a.preaprobado, a.preaprobado_fecha, a.preaprobado_usuario,a.usuario_modificacion, a.fecha_modificacion, a.estado,a.traslado,a.redistribuciones,a.consumido from tbl_con_cuenta_mensual a where a.anio = "+anio+" and a.cta1 = '"+cta1+"' and a.cta2 = '"+cta2+"' and a.cta3 = '"+cta3+"' and a.cta4 = '"+cta4+"' and a.cta5 = '"+cta5+"' and a.cta6 = '"+cta6+"' and a.compania ="+compania+"and a.unidad="+unidad+"  )b where a.column_value = b.mes(+) order by 2 asc";

	}

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
		if(confirm('Una vez que el presupuesto es ENVIADO no podrá efectuar modificaciones al mismo.  RECUERDE grabar los cambios hechos antes de Continuar!!!. Seguro que desea ejecutarlo?'))
		{
			window.frames['itemFrame'].doSubmit();
		}
	}
	else{
	window.frames['itemFrame'].doSubmit();}
}
function selCuenta()
{var unidad = document.form1.unidad.value;if(unidad!=''){abrir_ventana('../common/search_catalogo_gral.jsp?fp=presOp&unidad='+unidad);}else{ alert('Seleccione Unidad Administrativa.');}}
function selUnidad()
{
abrir_ventana('../inventario/sel_unid_ejec.jsp?fg=PRESOP');
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
function printPres(){
	 abrir_ventana("../presupuesto/print_presupuesto_ope.jsp?anio=<%=anio%>&unidad=<%=(unidad==null?"":unidad)%>");
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
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+ pres.getPresDetail().size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("estado",pres.getEstado())%>
<%=fb.hidden("usuarioCreacion",pres.getUsuarioCreacion())%>
<%=fb.hidden("fechaCreacion",pres.getFechaCreacion())%>
<%=fb.hidden("asignacionAnterior",pres.getAsignacionAnterior())%>
<%=fb.hidden("ejecutadoDic",pres.getEjecutadoDic())%>
<%=fb.hidden("ejecutado",pres.getEjecutado())%>
<%=fb.hidden("estadoAprob",pres.getEstadoAprob())%>
<%=fb.hidden("fechaAprob",pres.getFechaAprob())%>
<%=fb.hidden("usuarioAprob",pres.getUsuarioAprob())%>
<%=fb.hidden("companiaOrigen",pres.getCompaniaOrigen())%>
<%=fb.hidden("preaprobado",pres.getPreaprobado())%>
<%=fb.hidden("preaprobadoFecha",pres.getPreaprobadoFecha())%>
<%=fb.hidden("preaprobadoUsuario",pres.getPreaprobadoUsuario())%>
<%=fb.hidden("fechaEnvio",pres.getFechaEnvio())%>
<%=fb.hidden("fechaRechazo",pres.getFechaRechazo())%>

<tr>
	<td class="TableBorder">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader01">
			<td colspan="3"><cellbytelabel>PRESUPUESTO OPERATIVO PREELIMINAR</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td width="20%"><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
			<td width="60%">
				<% if (mode.equalsIgnoreCase("add")) { %>
				<%=fb.select("unidad",alUE,pres.getUnidad(),false,(!mode.equalsIgnoreCase("add")),0,null,null,null,null,"S")%>
				<% } else { %>
				<%=fb.select("unidad_display",alUE,pres.getUnidad(),false,(!mode.equalsIgnoreCase("add")),0,null,null,null,null,"S")%>
				<%=fb.hidden("unidad",pres.getUnidad())%>
				<% } %>
			</td>
			<td width="20%"><cellbytelabel>A&ntilde;o</cellbytelabel>:&nbsp;&nbsp;<%=fb.textBox("anio",pres.getAnio(),true,false,(viewMode|| !mode.trim().equals("add")),10)%></td>
		</tr>
		<tr class="TextRow02">
			<td>Cuenta</td>
			<td colspan="2"><%=fb.textBox("cta1",pres.getCta1(),true,false,true,5)%>
					<%=fb.textBox("cta2",pres.getCta2(),true,false,true,5)%>
					<%=fb.textBox("cta3",pres.getCta3(),true,false,true,5)%>
					<%=fb.textBox("cta4",pres.getCta4(),true,false,true,5)%>
					<%=fb.textBox("cta5",pres.getCta5(),true,false,true,5)%>
					<%=fb.textBox("cta6",pres.getCta6(),true,false,true,5)%>
					<%=fb.textBox("descCuenta",pres.getDescCuenta(),true,false,true,60)%>
					<%=fb.textBox("descTipoCta",pres.getDescTipoCta(),true,false,true,60)%>
					<%=fb.button("buscar","...",true,(viewMode|| !mode.trim().equals("add")),"","","onClick=\"javascript:selCuenta()\"")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
			<td><%//=fb.textBox("compania",pres.getCompania(),true,false,viewMode,10)%>
							<%//=fb.textBox("descCompania",pres.getDescCompania(),true,false,viewMode,40)%>
							<%=fb.select(ConMgr.getConnection(), "select codigo, nombre from tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId"), "compania",pres.getCompania(),false,viewMode, 0, "text10", "", "")%>
							<%//=fb.button("buscar","...",true,viewMode,"","","onClick=\"javascript:selCuenta()\"")%></td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td><cellbytelabel>Asignaci&oacute;n</cellbytelabel> Anual</td>
			<td><%=fb.decBox("asignacion_actual",pres.getAsignacionActual(),true,false,true,10,null,null,"")%></td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Justificaci&oacute;n</cellbytelabel></td>
			<td><%=fb.textarea("justificacion",pres.getJustificacion(),false,false,viewMode,80,2,2000)%></td>
			<td align="center">
			<%if(!fg.trim().equals("UPO")){%><span style="text-align:right; width:30%;">
				 <%=fb.button("print","Imprimir",true,false,"","height:60px","onClick=\"javascript:printPres()\"")%></span><%}%></td>
		</tr>


		<tr>
			<td colspan="3">
				<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../presupuesto/reg_presupuesto_det.jsp?mode=<%=mode%>&fg=<%=fg%>&lastLineNo=<%=lastLineNo%>"></iframe><!---->
			</td>
		</tr>
		<tr class="TextRow02">
			<%if(fg.trim().equals("UPO")){%>
			<td align="right"><cellbytelabel>Total de la  Distribución</cellbytelabel></td>
			<td align="center"><%=fb.decBox("total",pres.getAsignacionActual(),false,false,true,10,null,null,"")%></td>
			<td>&nbsp;</td>
			<%}else{%>
			<td align="right" colspan="2"><cellbytelabel>Total de la  Distribución</cellbytelabel> . . . </td>
			<td align="center"><%=fb.decBox("total",pres.getAsignacionActual(),false,false,true,10,null,null,"")%></td>
			<%}%>
		</tr>



		<tr class="TextRow02">
			<td colspan="3" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,viewMode)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%if(!fg.trim().equals("UPO")){%>&nbsp;&nbsp;&nbsp;&nbsp;<authtype type='50'><%=fb.button("sendBtn","Enviar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>&nbsp;&nbsp;&nbsp;&nbsp;</authtype><%}%>
				<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
	<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/list_presupuesto.jsp")) { %>
window.opener.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/list_presupuesto.jsp")%>&fg=<%=fg%>';
	<% } else { %>
window.opener.location='<%=request.getContextPath()%>/presupuesto/list_presupuesto.jsp?fg=<%=fg%>';
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
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&fg=<%=fg%>&anio=<%=anio%>&cta1=<%=cta1%>&cta2=<%=cta2%>&cta3=<%=cta3%>&cta4=<%=cta4%>&cta5=<%=cta5%>&cta6=<%=cta6%>&compania=<%=compania%>&unidad=<%=unidad%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>