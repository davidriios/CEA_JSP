<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr"/>
<jsp:useBean id="iCama" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCama" scope="session" class="java.util.Vector"/>
<jsp:useBean id="vCamaNew" scope="session" class="java.util.Vector"/>

<%
/**
==================================================================================
ADM3309
ADM3310_CON_SUP
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Admision adm = new Admision();
Admision resp = new Admision();
String key = "";
StringBuffer sbSql;
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String change = request.getParameter("change");
String fromNewView = request.getParameter("from_new_view");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");
String fecha="",fechaIngreso="";
int camaLastLineNo = 0;
int prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String estadoOptions = "A=ACTIVA,P=PRE-ADMISION,E=EN ESPERA";//,S=ESPECIAL se quita estado, soliciado el Mon, Aug 20, 2012 9:28 am por catherine.
String contCredOptions = "C=CONTADO, R=CREDITO";
String fp = request.getParameter("fp");
if (fg == null) fg = "";
if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view") || fg.equalsIgnoreCase("con_sup")) { viewMode = true; estadoOptions = "A=ACTIVA,P=PRE-ADMISION,S=ESPECIAL,E=EN ESPERA,I=INACTIVA,C=CANCELADA,N=ANULADA"; contCredOptions = "C=CONTADO, R=CREDITO"; }
if (fp == null) fp = "adm";
String loadInfo = request.getParameter("loadInfo");
if (loadInfo == null) loadInfo = "N";
if (fromNewView == null) fromNewView = "";
if (fechaNacimiento == null) fechaNacimiento = "";
if (codigoPaciente == null) codigoPaciente = "";

if (request.getMethod().equalsIgnoreCase("GET") && loadInfo.equals("S"))
{	
	if (mode.equalsIgnoreCase("add"))
	{
		iCama.clear();
		vCama.clear();
		vCamaNew.clear();
		if (pacId == null || pacId.trim().equals("")) pacId = "0";
		noAdmision = "0";
		adm.setPacId(pacId);
		adm.setNoAdmision(noAdmision);
		adm.setFechaIngreso(cDateTime.substring(0,10));
		adm.setAmPm(cDateTime.substring(11));
		adm.setFechaPreadmision("");
		adm.setEstado("A");
		adm.setTipoCta("P");

		int nRec = 0;
		StringBuffer sbFilter = new StringBuffer();
		if (!UserDet.getUserProfile().contains("0")) { sbFilter.append(" and d.codigo in (select cod_cds from tbl_cds_usuario_x_cds where usuario='"); sbFilter.append(session.getAttribute("_userName")); sbFilter.append("' and crea_admision='S')"); }
		nRec = CmnMgr.getCount("select count(*) from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_x_cds c, tbl_cds_centro_servicio d where a.categoria=b.codigo and a.categoria=c.cod_categoria and a.codigo=c.cod_tipo and c.cod_centro=d.codigo and d.estado='A' and a.compania="+((String) session.getAttribute("_companyId"))+sbFilter.toString()+"");
		if (nRec == 1)
		{
			CommonDataObject cdo = SQLMgr.getData("select a.categoria, a.codigo as tipoAdmision, a.descripcion as tipoAdmisionDesc, b.descripcion as categoriaDesc, d.codigo as centroServicio, d.descripcion as centroServicioDesc from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_x_cds c, tbl_cds_centro_servicio d where a.categoria=b.codigo and a.categoria=c.cod_categoria and a.codigo=c.cod_tipo and c.cod_centro=d.codigo and d.estado='A' and a.compania="+((String) session.getAttribute("_companyId"))+sbFilter.toString()+" order by d.descripcion, b.descripcion, a.descripcion");
			adm.setCategoria(cdo.getColValue("categoria"));
			adm.setCategoriaDesc(cdo.getColValue("categoriaDesc"));
			adm.setTipoAdmision(cdo.getColValue("tipoAdmision"));
			adm.setTipoAdmisionDesc(cdo.getColValue("tipoAdmisionDesc"));
			adm.setCentroServicio(cdo.getColValue("centroServicio"));
			adm.setCentroServicioDesc(cdo.getColValue("centroServicioDesc"));
		}
	}
	else
	{
		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");

		if (change == null)
		{
			iCama.clear();
			vCama.clear();
			vCamaNew.clear();

			sbSql = new StringBuffer();
			sbSql.append("select a.codigo, a.cama, a.habitacion, to_char(a.fecha_inicio,'dd/mm/yyyy') as fechaInicio, to_char(a.hora_inicio,'hh12:mi am') as horaInicio, nvl(a.precio_alt,'N') as precioAlt, a.precio_alterno as precioAlterno, a.motivo_precio_alt as motivoPrecioAlt, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, (select unidad_admin from tbl_sal_habitacion where compania=a.compania and codigo=a.habitacion) as centroServicio, (select y.descripcion from tbl_sal_habitacion z, tbl_cds_centro_servicio y where z.compania=a.compania and z.codigo=a.habitacion and z.unidad_admin=y.codigo) as centroServicioDesc, (select y.precio from tbl_sal_cama z, tbl_sal_tipo_habitacion y where z.compania=a.compania and z.habitacion=a.habitacion and z.codigo=a.cama and y.compania=a.compania and z.tipo_hab=y.codigo) as precio, (select y.descripcion||' - '||decode(y.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','O','OTROS','E','ECONOMICA','T','SUITE','Q','QUIROFANO','C','COMPARTIDA') from tbl_sal_cama z, tbl_sal_tipo_habitacion y where z.compania=a.compania and z.habitacion=a.habitacion and z.codigo=a.cama and y.compania=a.compania and z.tipo_hab=y.codigo) as habitacionDesc,case when to_date(to_char(a.fecha_inicio,'dd/mm/yyyy')||' '||to_char(a.hora_inicio,'hh12:mi am'),'dd/mm/yyyy hh12:mi am') + 3/24 > sysdate and a.fecha_final is null and (select estado from tbl_adm_admision where pac_id=a.pac_id and secuencia= a.admision )='A' then 1 else 0 end casoEspecial ,nvl(to_char(a.fecha_final,'dd/mm/yyyy'),' ') as fechaFinal, nvl(to_char(to_date(a.hora_final,'hh12:mi am'),'hh12:mi am'),' ') as horaFinal,(select count(*) from tbl_adm_cama_admision where pac_id = a.pac_id and admision= a.admision and fecha_final is null and hora_final is null )cantidadCa from tbl_adm_cama_admision a where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append("/* and a.fecha_final is null*/ order by 1");
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);
			System.out.println("SQL CAMA =============================================================================================================="+sbSql.toString());
			camaLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				Admision obj = (Admision) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				obj.setKey(key);

				try
				{
					iCama.put(key, obj);
					if(obj.getFechaFinal() == null || obj.getFechaFinal().trim().equals(""))
					{
						vCamaNew.addElement(obj.getHabitacion()+"-"+obj.getCama());
					}
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
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
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Admisión - '+document.title;
function showCamaList(){abrir_ventana1('../common/check_cama.jsp?fp=admision_new&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>');}
function usePrecioAlterno(k)
{
	if (eval('document.form1.precioAlt'+k).checked)
	{
		eval('document.form1.precioAlterno'+k).disabled = false;
		eval('document.form1.precioAlterno'+k).className = 'FormDataObjectEnabled';
	}
	else
	{
		eval('document.form1.precioAlterno'+k).disabled = true;
		eval('document.form1.precioAlterno'+k).className = 'FormDataObjectDisabled';
	}
	ctrlObsPrecioAlt(k);
}


function doAction(){
newHeight();
<%
	if (request.getParameter("type") != null && request.getParameter("type").equals("1")){
%>
	showCamaList();
<%
	}
%>
}


function chkDateCama(){
var camaSize=parseInt(document.form1.camaSize.value,10);
	for(i=1;i<=camaSize;i++)
	{
		var fecha_creacion =  eval('document.form1.fechaInicio'+i).value+ ' ' +eval('document.form1.horaInicio'+i).value;
		var time = 1;

		if(eval('document.form1.status'+i).value!='D' && eval('document.form1.casoEspecial'+i).value=='1')
		{
			if(fecha_creacion!='') time = getDBData('<%=request.getContextPath()%>','case when to_date(\''+fecha_creacion+'\',\'dd/mm/yyyy hh12:mi am\') + 3/24 > sysdate then 1 else 0 end','dual','','');
			if(time==0)
			{
				CBMSG.warning('La cama no puede ser borrada, ya pasaron las 3 horas disponibles que tenía para borrarlas!');
				return false;
			} //else return true;
		}
	}
	return true;
}
function chkEstadoAdm(){<%if(mode.trim().equals("edit")){%>if(hasDBData('<%=request.getContextPath()%>','tbl_adm_admision','secuencia=<%=noAdmision%> and pac_id=<%=pacId%> and estado=\'E\'','')){CBMSG.warning('La admisión está En Espera. No puede asignarle cama!');return false;}else return true;<%}else{%>return true;<%}%>}


function useOtherPrice()
{
	var camaSize=parseInt(document.form1.camaSize.value,10);
	for(i=1;i<=camaSize;i++)
	{
		if(eval('document.form1.status'+i).value!='D'&&eval('document.form1.precioAlt'+i).checked&&(eval('document.form1.precioAlterno'+i).value.trim()=='' || eval('document.form1.obsPrecioAlt'+i).value.trim()=='') )
		{
			CBMSG.warning('Usted ha marcado el Precio Alterno, por lo tanto debe introducir el monto del Precio Alterno y el motivo!');
			return false;
		}

	}
	return true;
}
//usePrecioAlterno()
function ctrlObsPrecioAlt(index){
	var rowObj = document.getElementById("obsPrecioAltRow"+index);
	var obsPrecioAlt = document.getElementById("obsPrecioAlt"+index);

	if (eval('document.form1.precioAlt'+index).checked ) {
		obsPrecioAlt.className = 'FormDataObjectEnabled';
		obsPrecioAlt.disabled = false;
		rowObj.style.display = '';
	}else{
		obsPrecioAlt.className = 'FormDataObjectDisabled';
		obsPrecioAlt.disabled = true;
		rowObj.style.display = 'none';
	}

}
function doSubmit(){
  <%if(!fromNewView.equals("")){%>
      document.form1.fechaNacimiento.value = "<%=fechaNacimiento%>";
	    document.form1.codigoPaciente.value = "<%=codigoPaciente%>";
	<%} else {%>
    document.form1.fechaNacimiento.value = parent.document.form0.fechaNacimiento.value;
	  document.form1.codigoPaciente.value = parent.document.form0.codigoPaciente.value;
	<%}%>
}
//window.notAValidDate;
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
	<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("tab","1")%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("fechaNacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigoPaciente", codigoPaciente)%>
	<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
	<%=fb.hidden("pacId",pacId)%>
	<%=fb.hidden("noAdmision",noAdmision)%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("camaSize",""+iCama.size())%>
	<%fb.appendJsValidation("if(document.form1.baction.value=='Guardar'&&!useOtherPrice())error++;");%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='X'&&!chkDateCama())error++;");%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&!chkEstadoAdm())error++;");%>
		<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader" align="center">
				<td width="4%"><cellbytelabel id="34">C&oacute;d.</cellbytelabel></td>
				<td width="5%"><cellbytelabel id="35">Cama</cellbytelabel></td>
				<td width="5%"><cellbytelabel id="33">Habitaci&oacute;n</cellbytelabel></td>
				<td width="18%"><cellbytelabel id="36">Sala o Secci&oacute;n</cellbytelabel></td>
				<td width="22%"><cellbytelabel id="15">Categor&iacute;a</cellbytelabel></td>
				<td width="7%"><cellbytelabel id="37">Precio</cellbytelabel></td>
				<td width="12%"><cellbytelabel id="38">Precio Alterno</cellbytelabel></td>
				<td width="12%">Fecha y Hora Asignaci&oacute;n</td>
				<td width="12%">Fecha y Hora Final</td>
				<td width="3%"><%=(vCamaNew.size() < 1 && (adm.getCantidadCa()!= null && !adm.getCantidadCa().equals("0")) && adm.getEstado()!= null && !adm.getEstado().equals("E"))?fb.submit("addCama","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Camas"):""%></td>
			</tr>
			<%
			al = CmnMgr.reverseRecords(iCama);
			for (int i=1; i<=iCama.size(); i++)
			{
				key = al.get(i - 1).toString();
				Admision obj = (Admision) iCama.get(key);
				String displayCama = "";
				if (obj.getStatus() != null && obj.getStatus().equalsIgnoreCase("D")) displayCama = " style=\"display:none\"";
			%>
			<%=fb.hidden("key"+i,obj.getKey())%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("codigo"+i,obj.getCodigo())%>
			<%=fb.hidden("cama"+i,obj.getCama())%>
			<%=fb.hidden("habitacion"+i,obj.getHabitacion())%>
			<%=fb.hidden("centroServicioDesc"+i,obj.getCentroServicioDesc())%>
			<%=fb.hidden("habitacionDesc"+i,obj.getHabitacionDesc())%>
			<%=fb.hidden("precio"+i,obj.getPrecio())%>
			<%=fb.hidden("fechaInicio"+i,obj.getFechaInicio())%>
			<%=fb.hidden("horaInicio"+i,obj.getHoraInicio())%>
			<%=fb.hidden("usuarioCreacion"+i,obj.getUsuarioCreacion())%>
			<%=fb.hidden("fechaCreacion"+i,obj.getFechaCreacion())%>
			<%=fb.hidden("usuarioModifica"+i,obj.getUsuarioModifica())%>
			<%=fb.hidden("fechaModifica"+i,obj.getFechaModifica())%>
			<%=fb.hidden("casoEspecial"+i,obj.getCasoEspecial())%>
			<%=fb.hidden("status"+i,obj.getStatus())%>
			<%=fb.hidden("fechaFinal"+i,obj.getFechaFinal())%>
			<%=fb.hidden("horaFinal"+i,obj.getHoraFinal())%>
			<tr class="TextRow01"<%=displayCama%>>
				<td align="center"><%=obj.getCodigo()%></td>
				<td align="center"><%=obj.getCama()%></td>
				<td align="center"><%=obj.getHabitacion()%></td>
				<td><%=obj.getCentroServicioDesc()%></td>
				<td><%=obj.getHabitacionDesc()%></td>
				<td align="right"><%=CmnMgr.getFormattedDecimal(obj.getPrecio())%></td>
				<td>
					<%=fb.checkbox("precioAlt"+i,"S",(obj.getPrecioAlt() != null && obj.getPrecioAlt().equalsIgnoreCase("S")),(viewMode||(obj.getCasoEspecial() != null && !obj.getCasoEspecial().trim().equals("")&& obj.getCasoEspecial().trim().equals("0"))),null,null,"onClick=\"javascript:usePrecioAlterno("+i+")\"","Utilizar Precio Alterno")%>
					<%=fb.decBox("precioAlterno"+i,obj.getPrecioAlterno(),false,!(obj.getPrecioAlt() != null && obj.getPrecioAlt().equalsIgnoreCase("S")),viewMode,10,8.2)%>
				</td>
				<td align="center"><%=obj.getFechaInicio()%> <%=obj.getHoraInicio()%></td>
				<td align="center"><%=obj.getFechaFinal()%> <%=obj.getHoraFinal()%></td>
				<td align="center"><%=fb.submit("rem"+i,"X",true,(viewMode||(obj.getCasoEspecial() != null && !obj.getCasoEspecial().trim().equals("")&& obj.getCasoEspecial().trim().equals("0"))),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Cama")%></td>
			</tr>
			<tr class="TextRow01" id="obsPrecioAltRow<%=i%>" <%=displayCama%>>
				<td colspan="3">Motivo del precio alternativo</td>
				<td colspan="7"><%=fb.textarea("obsPrecioAlt"+i,obj.getMotivoPrecioAlt(),false,!(obj.getPrecioAlt() != null && obj.getPrecioAlt().equalsIgnoreCase("S")),viewMode,100,2,200)%>
				</td>
			</tr>
			<%
			}
			%>
			</table>
		</td>
	</tr>

	<tr class="TextRow02">
		<td align="right">
			<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
			<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
			<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
			<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
			<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value);doSubmit();\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
		</td>
	</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else if(request.getMethod().equalsIgnoreCase("POST"))
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = "";
	String errMsg = "";

	adm = new Admision();
	adm.setPacId(request.getParameter("pacId"));
	adm.setNoAdmision(request.getParameter("noAdmision"));
	adm.setFechaNacimiento(request.getParameter("fechaNacimiento"));
	adm.setCodigoPaciente(request.getParameter("codigoPaciente"));
	adm.setCompania((String) session.getAttribute("_companyId"));
	adm.setUsuarioModifica((String) session.getAttribute("_userName"));
		int size = 0;
		if (request.getParameter("camaSize") != null) size = Integer.parseInt(request.getParameter("camaSize"));
		String itemRemoved = "";

		adm.getCamas().clear();
		for (int i=1; i<=size; i++)
		{
			Admision obj = new Admision();

			obj.setCodigo(request.getParameter("codigo"+i));
			obj.setHabitacion(request.getParameter("habitacion"+i));
			obj.setCama(request.getParameter("cama"+i));
			obj.setCentroServicio(request.getParameter("centroServicio"+i));
			obj.setCentroServicioDesc(request.getParameter("centroServicioDesc"+i));
			obj.setPrecio(request.getParameter("precio"+i));
			if (request.getParameter("precioAlt"+i) != null && request.getParameter("precioAlt"+i).equalsIgnoreCase("S"))
			{
				obj.setPrecioAlt("S");
				obj.setPrecioAlterno(request.getParameter("precioAlterno"+i));

				obj.setMotivoPrecioAlt(request.getParameter("obsPrecioAlt"+i));
			}
			else
			{
				obj.setPrecioAlt("N");
				obj.setPrecioAlterno("");
			}
			obj.setHabitacionDesc(request.getParameter("habitacionDesc"+i));
			obj.setFechaInicio(request.getParameter("fechaInicio"+i));
			obj.setHoraInicio(request.getParameter("horaInicio"+i));
			obj.setUsuarioCreacion((String) session.getAttribute("_userName"));
			obj.setUsuarioModifica((String) session.getAttribute("_userName"));
			obj.setKey(request.getParameter("key"+i));
			obj.setCasoEspecial(request.getParameter("casoEspecial"+i));

			obj.setFechaFinal(request.getParameter("fechaFinal"+i));
			obj.setHoraFinal(request.getParameter("horaFinal"+i));


			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = obj.getKey();
				obj.setStatus("D");//D=Delete action in AdmisionMgr
				vCama.remove(obj.getHabitacion()+"-"+obj.getCama());
				vCamaNew.remove(obj.getHabitacion()+"-"+obj.getCama());
			}
			else obj.setStatus(request.getParameter("status"+i));

			try
			{
				iCama.put(obj.getKey(),obj);
				adm.addCama(obj);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}

		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&loadInfo=S&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&loadInfo=S&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AdmMgr.saveCama(adm);
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();
	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
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
	if (parent.window) parent.window.close();
	else window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&loadInfo=S&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&loadInfo=S&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>