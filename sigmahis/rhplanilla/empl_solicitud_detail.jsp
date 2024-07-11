<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
String change = request.getParameter("change");
String numEmpleado = "";
String empId = request.getParameter("empId");
String seccion = "";
String area = "";
String grupo = "";
if(empId==null) empId = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");

if (request.getMethod().equalsIgnoreCase("GET"))
{

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Solicitud  de Vacaciones - '+document.title;

function doSubmit(){
	if(formVacacionValidation()){
	  document.formVacacion.save.disableOnSubmit = true;
	  var x=0;
	  var empleados ='';

	  if (parent.doRedirect('4','0') == true){
		document.formVacacion.grupo.value = parent.frames['iEmpleado'].document.formEmpleado.grupo.value;
		 verificaVacacion();
			if(!isNaN(document.formVacacion.size.value)) x =  parseInt(document.formVacacion.size.value);
		}
		document.formVacacion.baction.value = "Guardar";
		if(formVacacionValidation())if(x> 0 && document.formVacacion.fecha.value !=''){ document.formVacacion.submit(); parent.unCheckAll('2'); }else return false;
		}
}
function doAction()
{
	newHeight();
	parent.setHeight('secciones',document.body.scrollHeight);
	for (i=0; i<<%=iEmp.size()%>; i++){
		if(eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked){
			document.formVacacion.provincia.value = eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value;
			document.formVacacion.sigla.value = eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value;
			document.formVacacion.tomo.value = eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value;
			document.formVacacion.asiento.value = eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value;
			document.formVacacion.numEmpleado.value = eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value;
			document.formVacacion.empId.value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
			document.formVacacion.cargo_empleado.value = eval("parent.frames['iEmpleado'].document.formEmpleado.cargo"+i).value;
			//eval("document.formVacacion.check"+i).value = 'S';

		}
	}
}

function addMotivo(index)
{
   abrir_ventana1("../common/search_motivo_falta.jsp?fp=vacacion_empleado&index="+index);
}
function addLicencia(index)
{
   var inact ="";
   {
   abrir_ventana1("../common/search_motivo_licencia.jsp?fp=vacacion_empleado&index="+index);
}
}

function addPert()
{

var i=0;
var group = parent.frames['iEmpleado'].document.formEmpleado.grupo.value;
  abrir_ventana1("../common/search_empleado_otros.jsp?fp=solicitud_vac&grupo="+group);
}

function chkReemplazo(){
	if(document.formVacacion.contratar.checked){
	document.formVacacion.codPert.value='';
	document.formVacacion.pertDesc.value='';
	document.formVacacion.cargoRem.value='';
	document.formVacacion.btnpert.disabled=true;
	} else {
		document.formVacacion.btnpert.disabled=false;
	}
}

function setReemplazoValues(){
	var numId = eval('document.formVacacion.codPert').value
	var empl = getDBData('<%=request.getContextPath()%>','a.codigo, a.denominacion, a.tipo_puesto','tbl_pla_cargo a, tbl_pla_empleado b','a.compania = b.compania and a.codigo = b.cargo and to_char(b.num_empleado) = '+numId+'','');
	var arr_cursor = new Array();
	if(empl!=''){
		arr_cursor = splitCols(empl);
		if(arr_cursor[0]!=' ') document.formVacacion.cargo_reemplazo.value				= arr_cursor[0];
		if(arr_cursor[1]!=' ') document.formVacacion.cargoRem.value			= arr_cursor[1];
		if(arr_cursor[2]!='') document.formVacacion.tipo_puesto.value	= arr_cursor[2];
		else {
			alert('EL CODIGO DE CARGO DEL EMPLEADO NO TIENE ASIGNADO UN TIPO DE PUESTO (CONFIANZA O SINDICATO) , ESTO ES REQUERIDO PARA VALIDAR SI EL REEMPLAZO PUEDE RECIBIR BONIFICACION, REVISE MANTENIMIENTO DE CARGOS');

		}
	}
}

function setTipoBonificacion(){
	var tipo_puesto = document.formVacacion.tipo_puesto.value;
	var cargo_emp = document.formVacacion.cargo_empleado.value;
	var cargo_reemp = document.formVacacion.cargo_reemplazo.value;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	var bonif_por_reemplazo = document.formVacacion.bonif_por_reemplazo.value;
	var diferencia_por_reemplazo = '';
	if (tipo_puesto == ''){
		alert('EL CODIGO DE CARGO DEL EMPLEADO NO TIENE ASIGNADO UN TIPO DE PUESTO (CONFIANZA O SINDICATO) , ESTO ES REQUERIDO PARA VALIDAR SI EL REEMPLAZO PUEDE RECIBIR BONIFICACION, REVISE MANTENIMIENTO DE CARGOS, NO CALCULARA BONIF.');
		bonif_por_reemplazo = 'D';
		diferencia_por_reemplazo = 0;
	}
	if(tipo_puesto == 2){                                                    		/* SINDICALIZADOS*/
		if(bonif_por_reemplazo == 'A') diferencia_por_reemplazo = 100;					/*     JEFE      */
		else if(bonif_por_reemplazo == 'B') diferencia_por_reemplazo = 75;			/*   SUPERVISOR  */
		else if(bonif_por_reemplazo == 'C'){
			if(executeDB('<%=request.getContextPath()%>','call sp_rh_calcula_reemplazo(<%=(String) session.getAttribute("_companyId")%>, \'' + cargo_emp + '\', \'' + cargo_reemp + '\')')){
				var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
				var arr_cursor = new Array();
				if(msg!=''){
					arr_cursor = splitCols(msg);
					diferencia_por_reemplazo	= arr_cursor[0];
					bonif_por_reemplazo				= arr_cursor[1];
				}
			} else {
				var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
				alert(msg);
				bonif_por_reemplazo = 'D';
				diferencia_por_reemplazo = 0;
			}
		} else if(bonif_por_reemplazo == 'D') diferencia_por_reemplazo = 0;		/*    NO APLICA  */
	} else if (tipo_puesto == 1){
		alert('ESTE EMPLEADO ES CONSIDERADO COMO PERSONAL DE CONFIANZA, NO RECIBE BONIFICACION');
		bonif_por_reemplazo = 'D';
		diferencia_por_reemplazo = 0;
	}
	document.formVacacion.diferencia_por_reemplazo.value	= diferencia_por_reemplazo;
	document.formVacacion.bonif_por_reemplazo.value				= bonif_por_reemplazo;
}

function setFinalDate(empIdNew,noEmpl){
	var f_ini = document.formVacacion.fecha.value;
	var dias = document.formVacacion.diaTiempo.value;
	var empId = '';
	var noEmpleado = '';

    empId = empIdNew;
	noEmpleado=noEmpl;
	if(empId!=''){
	var x = getDBData('<%=request.getContextPath()%>','count(*)','tbl_pla_sol_vacacion','emp_id='+empId+' and to_date(to_char(periodof_inicio, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') >= to_date(\''+f_ini+'\',\'dd/mm/yyyy\') and dias_tiempo > 0 and estado  not in (\'AN\', \'RE\') and compania = <%=(String) session.getAttribute("_companyId")%>','');
	if(x!='0'){ alert('El empleado No. '+noEmpleado+' ya tiene registrada vacaciones para esta fecha!');document.formVacacion.fecha.value='';return false;}
	else{if(dias !='' && dias!='0'){if(f_ini!=''){ var f_fin = getDBData('<%=request.getContextPath()%>','to_char(to_date (\''+f_ini+'\', \'dd/mm/yyyy\')-1+ '+dias+', \'dd/mm/yyyy\')','dual','','');
	document.formVacacion.fechaFin.value = f_fin;return true;}}else{ alert('Introduzca dias Tiempo');document.formVacacion.fecha.value='';return false;}}
	}
}

function setFPReadOnly(value){
var valor = '';
valor = 0;
	document.formVacacion.diaTiempo.value = '';
	document.formVacacion.diaDinero.value = '';
	if(value=='TD'){
		document.formVacacion.diaTiempo.readOnly=false;
		document.formVacacion.diaDinero.readOnly=false;
	} else if(value=='TI'){
		document.formVacacion.diaTiempo.readOnly=false;
		document.formVacacion.diaDinero.readOnly=true;
		document.formVacacion.diaDinero.value	= valor;
	} else if(value=='DI'){
		document.formVacacion.diaTiempo.readOnly=true;
		document.formVacacion.diaDinero.readOnly=false;
		document.formVacacion.diaTiempo.value	= valor;
	}
}

function verificaVacacion(){
   var empleados='';
   var x =0;
	for (i=0; i<<%=iEmp.size()%>; i++){
			if(eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked){
				document.formVacacion.provincia.value = eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value;
				document.formVacacion.sigla.value = eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value;
				document.formVacacion.tomo.value = eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value;
				document.formVacacion.asiento.value = eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value;
				document.formVacacion.numEmpleado.value = eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value;
				document.formVacacion.empId.value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
				document.formVacacion.cargo_empleado.value = eval("parent.frames['iEmpleado'].document.formEmpleado.cargo"+i).value;

				if(setFinalDate(eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value,eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value)){
				if(x>0)empleados =empleados +'|';
				empleados  = empleados + eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value+'-'+eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value+'-'+eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value+'-'+eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value+'-'+eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value+'-'+eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value+'-'+eval("parent.frames['iEmpleado'].document.formEmpleado.cargo"+i).value;
				}
				x++;
			}
			}
			document.formVacacion.empleados.value = empleados;
			document.formVacacion.size.value = x;

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="1" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("formVacacion",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("area",area)%>
				<%=fb.hidden("ue_codigo",grupo)%>
				<%=fb.hidden("grupo",grupo)%>
				<%=fb.hidden("numId","")%>
				<%=fb.hidden("cargo_empleado","")%>
				<%=fb.hidden("cargo_reemplazo","")%>
				<%=fb.hidden("provincia","")%>
				<%=fb.hidden("sigla","")%>
				<%=fb.hidden("tomo","")%>
				<%=fb.hidden("asiento","")%>
				<%=fb.hidden("r_provincia","")%>
				<%=fb.hidden("r_sigla","")%>
				<%=fb.hidden("r_tomo","")%>
				<%=fb.hidden("r_asiento","")%>
				<%=fb.hidden("tipo_puesto","")%>
				<%=fb.hidden("numEmpleado","")%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("empleados","")%>
				<%=fb.hidden("size","0")%>
        <tr class="TextRow01">
          <td width="248"></td>
          <td width="309"> <cellbytelabel>REGISTRO DE SOLICITUD DE VACACIONES</cellbytelabel> </td>
          <td width="328"></td>
        </tr>
        <tr class="TextRow02">
          <td width="248"><cellbytelabel>Fecha de Solicitud</cellbytelabel> </td>
          <td width="309">&nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("dateRec",cDateTime.substring(0,10),false,false,true,10)%>&nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.hidden("estado","")%>
					<%=fb.textBox("dsp_estado","Pendiente",false,false,true,10,10)%>
					<%=fb.hidden("anio",cDateTime.substring(6,10))%>
          </td>
          <td width="328"><cellbytelabel>C&oacute;digo</cellbytelabel>&nbsp;&nbsp;
					<%=fb.intBox("codigo","0",false,false,true,10,1)%>
          </td>
        </tr>
        <tr class="TextHeader" >&nbsp;&nbsp;&nbsp;
          <td colspan="3">&nbsp;</td>
        </tr>
        <tr class="TextRow01">
          <td><cellbytelabel>Tiempo Solicitado</cellbytelabel> </td>
          <td>Tiempo <%=fb.intBox("diaTiempo","",true,false,false,5,5,"Text10",null,"onChange=\"javascript:setFinalDate(0,0)\"")%>&nbsp;&nbsp;
            <cellbytelabel>Dinero</cellbytelabel> <%=fb.intBox("diaDinero","",true,false,false,5,5,"Text10",null,null)%></td>
          <td>Forma de Pago&nbsp;&nbsp;<%=fb.select("tipo","TD=Tiempo y Dinero,TI=Tiempo,DI=Dinero","",false,false,0,"Text10",null,"onChange= \"javascript:setFPReadOnly(this.value);\"")%></td>
        </tr>
        <tr class="TextRow02">
          <td><cellbytelabel>Fecha Solicitada</cellbytelabel></td>
          <td><cellbytelabel>Inicio de Vacaciones</cellbytelabel>
            <jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="fecha"/>
            <jsp:param name="valueOfTBox1" value="" />
            <jsp:param name="jsEvent" value="verificaVacacion()"/>
            <jsp:param name="onChange" value="verificaVacacion()"/>
			<jsp:param name="resetFrameHeight" value="y" />
			<jsp:param name="appendOnClickEvt" value="if(document.body.scrollHeight<275)parent.setHeight(\'iDetalle\',300);" />
			</jsp:include>
          </td>
          <td><cellbytelabel>Final de Vacaciones</cellbytelabel>
            <jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="fechaFin"/>
            <jsp:param name="valueOfTBox1" value="" />
			<jsp:param name="resetFrameHeight" value="y" />
			<jsp:param name="appendOnClickEvt" value="if(document.body.scrollHeight<275)parent.setHeight(\'iDetalle\',300);" />
            </jsp:include>
          </td>
        </tr>



        <tr class="TextRow01" >
          <td><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
          <td colspan="2"><%=fb.textarea("motivo","",false,false,false,77,3)%></td>
        </tr>
        <tr class="TextRow02">
          <td align="right" colspan="9">
					<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%>
					<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0,1)\"")%>
          </td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
</body>
</html>
<%
}//GET
else
{

	seccion = request.getParameter("seccion");
	area = request.getParameter("area");
	grupo = request.getParameter("grupo");


	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
	String sVal = "",sValDet="";
	StringTokenizer st = new StringTokenizer(request.getParameter("empleados"),"|");
	 int maxLine = st.countTokens();
	 System.out.println("empleados = "+request.getParameter("empleados"));
	while(st.hasMoreElements())
    {
      CommonDataObject cdo = new CommonDataObject();
	  String noEmpleado ="",provincia="",sigla="",tomo="",asiento="",emp_id="";
	  int nLine =0;
	    sVal = st.nextToken().trim();
		StringTokenizer stDet = new StringTokenizer(sVal,"-");
		maxLine = stDet.countTokens();
		while(stDet.hasMoreElements())
    	{
			nLine ++;
			sValDet = stDet.nextToken().trim();
			if(nLine==1)provincia=sValDet;
			if(nLine==2)sigla=sValDet;
			if(nLine==3)tomo=sValDet;
			if(nLine==4)asiento=sValDet;
			if(nLine==5)emp_id=sValDet;
			if(nLine==6)noEmpleado=sValDet;
		}

			cdo.setTableName("tbl_pla_sol_vacacion");
			cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and emp_id="+emp_id);
		 	cdo.addColValue("provincia",provincia);
		 	cdo.addColValue("sigla",sigla);
		 	cdo.addColValue("tomo",tomo);
		 	cdo.addColValue("asiento",asiento);
		 	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("num_empleado",noEmpleado);
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("fecha_solicitud",request.getParameter("dateRec"));
			cdo.addColValue("anio",request.getParameter("anio"));
			cdo.addColValue("codigo",request.getParameter("codigo"));
			cdo.setAutoIncCol("codigo");

			cdo.addColValue("dias_tiempo",request.getParameter("diaTiempo"));
			cdo.addColValue("dias_dinero",request.getParameter("diaDinero"));

			cdo.addColValue("estado","PE");
			cdo.addColValue("tipo",request.getParameter("tipo"));

			cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("periodof_inicio",request.getParameter("fecha"));
			cdo.addColValue("periodof_final",request.getParameter("fechaFin"));
			cdo.addColValue("observacion",request.getParameter("motivo"));
	//cdo.addColValue("r_num_empleado",request.getParameter("codPert"));
	//cdo.addColValue("cargo_empleado",request.getParameter("cargo_empleado"));
	//cdo.addColValue("cargo_reemplazo",request.getParameter("cargo_reemplazo"));
	//cdo.addColValue("bonif_por_reemplazo",request.getParameter("bonif_por_reemplazo"));
	//if(request.getParameter("diferencia_por_reemplazo")!=null && !request.getParameter("diferencia_por_reemplazo").equals("")) cdo.addColValue("diferencia_por_reemplazo",request.getParameter("diferencia_por_reemplazo"));
	//if(request.getParameter("r_provincia")!=null && !request.getParameter("r_provincia").equals("")) cdo.addColValue("r_provincia",request.getParameter("r_provincia"));
	//if(request.getParameter("r_sigla")!=null && !request.getParameter("r_sigla").equals("")) cdo.addColValue("r_sigla",request.getParameter("r_sigla"));
	//if(request.getParameter("r_tomo")!=null && !request.getParameter("r_tomo").equals("")) cdo.addColValue("r_tomo",request.getParameter("r_tomo"));
	//if(request.getParameter("r_asiento")!=null && !request.getParameter("r_asiento").equals("")) cdo.addColValue("r_asiento",request.getParameter("r_asiento"));
			list.add(cdo);

    }

    }
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.insertList(list,true,false);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_solicitud_detail.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_solicitud_detail.jsp")%>';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/rhplanilla/empl_solicitud_detail.jsp?area=<%=area%>&grupo=<%=grupo%>&seccion=<%=seccion%>';
<%
	}
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
