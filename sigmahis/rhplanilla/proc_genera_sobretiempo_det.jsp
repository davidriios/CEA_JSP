<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="VacMgr" scope="page" class="issi.rhplanilla.VacacionesMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htajus" scope="session" class="java.util.Hashtable" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
VacMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList aj = new ArrayList();
ArrayList al = new ArrayList();
ArrayList sec = new ArrayList();
String key = "";
String sql = "";
String appendFilter = "";
String appendFilter1 = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String planilla = request.getParameter("planilla");
String seccion = request.getParameter("seccion");
String cia = (String) session.getAttribute("_companyId");
String empId = request.getParameter("empid");

String periodo = request.getParameter("periodo");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String cierre = request.getParameter("cierre");
String grupo = request.getParameter("grupo");
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");

String trxId = request.getParameter("trx");
String tipoId = request.getParameter("tipo");

String fecha="",fechaIngreso="";
int benLastLineNo = 0, prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anioC = CmnMgr.getCurrentDate("yyyy");
String meses = CmnMgr.getCurrentDate("mm");
String dia = CmnMgr.getCurrentDate("dd");
String userName = UserDet.getUserName();
int per = 0;
double total = 0.00;
int iconHeight = 48;
int iconWidth = 48;
int ajusLastLineNo = 0;
boolean viewMode = false;

//if(request.getParameter("extraLastLineNo")!=null && ! request.getParameter("extraLastLineNo").equals(""))
//extraLastLineNo=Integer.parseInt(request.getParameter("extraLastLineNo"));
//else extraLastLineNo=0;

int day = Integer.parseInt(CmnMgr.getCurrentDate("dd"));
int mont = Integer.parseInt(CmnMgr.getCurrentDate("mm"));
if (tab == null) tab = "0";


if(day >16) per = mont*2;
else per =  mont*2-1;

	if (anio == null) anio = anioC;
	if (periodo == null) periodo = ""+per;

if (grupo == null) grupo = "";
if (!grupo.equals(""))
{
	appendFilter += " and a.grupo="+grupo;
	appendFilter1 += " and s.ue_codigo="+grupo;
}

 if ((mode.equalsIgnoreCase("view")) &&  (grupo == null)) appendFilter = " and a.grupo = 0";

//if (mode.equalsIgnoreCase("view")) viewMode = true;


if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (mode.equalsIgnoreCase("view"))
	{
		if (anio == null) throw new Exception("El Año no es válido. Por favor intente nuevamente!");
		 if (periodo == null) throw new Exception("El Periodo no es válido. Por favor intente nuevamente!");
	    if (mes == null) throw new Exception("El Mes no es válido. Por favor intente nuevamente!");

	htajus.clear();
		sql="select to_char(a.provincia)||'-'||a.sigla||'-'|| to_char(a.tomo,'0999')||'-'||to_char(a.asiento,'099999') cedula, b.primer_nombre||' '||decode(b.sexo,'F',decode(b.apellido_casada,null,b.primer_apellido, decode(b.usar_apellido_casada,'S','DE '||b.apellido_casada,b.primer_apellido)),b.primer_apellido) as nombre, a.num_empleado||' - '||a.emp_id as numEmpleado, a.emp_id, a.grupo, c.descripcion as estado from tbl_pla_ct_empleado a, tbl_pla_empleado b, tbl_pla_estado_emp c, tbl_pla_calendario d where a.emp_id = b.emp_id and a.compania = b.compania and b.estado = c.codigo and	(a.fecha_egreso_grupo is null or a.fecha_egreso_grupo > to_date('"+desde+"','dd/mm/yyyy')  ) and (a.emp_id) in (select distinct s.emp_id from tbl_pla_st_det_turext s, tbl_pla_empleado e where	e.emp_id = s.emp_id and e.compania	= s.compania and s.periodo_pago = "+periodo+" and s.anio_pago = "+anio+"  and s.aprobado = 'S' and e.compania = "+(String) session.getAttribute("_companyId")+appendFilter1+") and  a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and d.tipopla = 1 and d.periodo = "+periodo+" order by a.num_empleado";

		aj=SQLMgr.getDataList(sql);
		System.out.println("ajuste size="+aj.size()+"///"+grupo);
		System.out.println("sql="+sql);
		ajusLastLineNo= aj.size();
		for(int i=1; i<=aj.size(); i++)
		{
		CommonDataObject cdo3 = (CommonDataObject) aj.get(i-1);
		if(i<10)  key = "00"+i;
		else if(i<100)
		key = "0"+i;
		else
		key= ""+i;
		cdo3.addColValue("key",key);
		try {
		htajus.put(key,cdo3);

		}//End Try
		catch (Exception e)
		{
		System.err.println(e.getMessage());
		}//End Catch
		}//End for
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function procEjecutar()
{
var msg   ="";
var cont = 0;
var cont1 = 0;
var cadena = "";
var empId = "";
var ajusSize  = parseInt(eval('document.form3.ajusSize').value);
var anio = eval('document.form3.anio').value;
var periodo = eval('document.form3.periodo').value;
var mes = eval('document.form3.mes').value;
var quincena = eval('document.form3.quincena').value;
var cierre = eval('document.form3.cierre').value;
var grupo = eval('document.form3.grupo').value;

var desde = eval('document.form3.desde').value;
var hasta = eval('document.form3.hasta').value;
var estado = "1";
var user = "<%=(String) session.getAttribute("_userName")%>";
var temp = "";	///		showPopWin('../common/run_process.jsp?fp=DISTTRX&actType=51&docType=DISTTRX&periodo='+periodo+'&anio='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&estado='+estado+'&anioPago='+anio+'&quincenaPago='+periodo+'&empId='+cadena+'&grupo='+grupo+'&usuario='+user,winWidth*.75,winHeight*.65,null,null,'');
	if(confirm('Está seguro que desea ejecutar el proceso de Generación y Distribución de Sobretiempo ?...'))
	{


		for(i=0;i<ajusSize;i++)
		{
			if (eval('document.form3.check'+i).checked)
				{
			 empId = eval('document.form3.emp_id'+i).value;
			 grupo = eval('document.form3.grupo'+i).value;
	//  alert('Antes del llamado!');
						if (grupo=="") grupo = "null";

					if(executeDB('<%=request.getContextPath()%>','call sp_pla_distribucion_extra('+periodo+','+anio+','+empId+',<%=cia%>,'+grupo+',\''+desde+'\',\''+hasta+'\',\''+user+'\')'));
					{
							
							cont1++;
							
			 		} //else alert('No se han generado los Sobretiempos Consulte al Administrador!');



		}
	}

	} else alert('Proceso Cancelado por el Usuario ...!'); // confirm
	if(cont1>0)
		{
				document.form3.ejecutar.readOnly = true;
				alert('La Generacion de Sobretiempos se generó Satisfactoriamente!');
				//window.opener.location = '<%=request.getContextPath()%>/rhplanilla/proc_generacion_sobretiempo.jsp?mode=view';
				//window.close();
	
	}

}

function procEliminar()
{
var msg   ="";
var cont = 0;
var cont1 = 0;
var filter ="";
var size  = parseInt(eval('document.form3.ajusSize').value);
	if(confirm('Está seguro que desea eliminar la Distribución de Sobretiempo ?...'))
	{
		for(i=0;i<size;i++)
		{
				if (eval('document.form3.check'+i).checked)
				{
						var anio 			= eval('document.form3.anio'+i).value;
						var periodo 	= eval('document.form3.periodo'+i).value;
						var mes				= eval('document.form3.mes'+i).value;
						var quincena 	= eval('document.form3.quincena'+i).value;
						var cierre 		= eval('document.form3.cierre'+i).value;
						var grupo 		= eval('document.form3.grupo'+i).value;
						var desde 		= eval('document.form3.desde'+i).value;
						var hasta 		= eval('document.form3.hasta'+i).value;
						var emp_id 	= eval('document.form3.emp_id'+i).value;

					 	if(executeDB('<%=request.getContextPath()%>','delete from tbl_pla_st_det_disttur where compania = <%=cia%> and anio_pago = '+anio+' and periodo_pago = '+periodo+'  and emp_id = '+emp_id+' and (trx_generada = \'N\'  or trx_generada is null ) and ue_codigo = '+grupo+' ','tbl_pla_st_det_disttur'))
						{
						 		if(executeDB('<%=request.getContextPath()%>','UPDATE tbl_pla_st_det_turext SET distribuido = \'N\', fecha_distribucion =  null WHERE aprobado = \'S\' and actualizado = \'S\' and anio_pago = \''+anio+'\' and periodo_pago ='+periodo+' and emp_id ='+emp_id+' and ue_codigo = '+grupo+' and compania = <%=(String) session.getAttribute("_companyId")%>','tbl_pla_st_det_turext'))
							 {
									cont1++;
									//document.form3.eliminar.readOnly = true;
									//alert('****** P R O C E S O   D E   D I S T I B U C I O N   F I N A L I Z A D O ******');

							 } //else cont1++;
						}

			 }  else
					{
						cont += 1;
						if(size==cont)
						alert('No hay transacción chequeada...Revise!!!');// if checked
					}

		} // end for

	} else alert('Proceso Cancelado por el Usuario ...!'); // confirm

	if(cont1>0)
	{
			document.form3.eliminar.readOnly = true;
			alert('****** P R O C E S O   D E   E L I M I N A C I O N   F I N A L I Z A D O ******');
			//window.opener.location = '<%=request.getContextPath()%>/rhplanilla/proc_generacion_sobretiempo.jsp?mode=view';
			//window.close();

	}
}


function doAction()
{
	verCheck();
}

function verCheck()
{
var size = parseInt(eval('document.form3.ajusSize').value);
var totalCheck = 0;
var est = "'D'";
var an=0;
var num=0;
var cod=0;

if(size>0)
	{
for (i=0;i< size;i++)
		{
		an  = eval('document.form3.anio'+i).value;
		num = eval('document.form3.periodo'+i).value;
		cod = eval('document.form3.emp_id'+i).value;

			if (eval('document.form3.check'+i).checked)
				{
							totalCheck += 1;
				}
		}
	document.getElementById("cont").value=totalCheck;
	}
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}

function doSubmit(action){
	document.form3.baction.value 			= action;
	document.form3.anio.value 			= parent.document.form1.anio.value;
	document.form3.mes.value 			= parent.document.form1.mes.value;
	document.form3.quincena.value 			= parent.document.form1.quincena.value;
	if(action == 'EJECUTAR' ){
		formBlockButtons(true);
		if(chkSelected()) document.form3.submit();
		else alert('Seleccione al menos un Registro!');
		formBlockButtons(false);
	}
		if(action == 'ELIMINAR'){
		formBlockButtons(true);
		if(chkSelected()) document.form3.submit();
		else alert('Seleccione al menos un Registro!');
		formBlockButtons(false);
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
			<tr class="TextRow02">
			  <td>&nbsp;</td>
			</tr>
			<tr class="TextRow02">
			  <td>&nbsp;</td>
			</tr>



	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
			<tr>
				<td>

<!-- MAIN DIV START HERE -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================   F O R M   S T A R T   H E R E  ============== -->


<%fb = new FormBean("form3",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","3")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("ajusSize",""+aj.size())%>
				<%=fb.hidden("keySize",""+aj.size())%>
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("grupo",grupo)%>
				<%=fb.hidden("mes",mes)%>
				<%=fb.hidden("quincena",quincena)%>
				<%=fb.hidden("cierre",cierre)%>
				<%=fb.hidden("desde",desde)%>
				<%=fb.hidden("hasta",hasta)%>
				<%=fb.hidden("clearHT","")%>


	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>

	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;Selección</td>
					<td width="5%"><%=fb.checkbox("chk","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+aj.size()+",this);verCheck()\"","Seleccionar todos los Empleados. !")%></td>
				</tr>
			</table>
		</td>
	</tr>

	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
				<tr class="TextHeader" align="center">
					<td width="10%">Grupo</td>
					<td width="15%"># Empleado</td>
					<td width="45%">Nombre del Colaborador</td>
					<td width="20%">Estado</td>
					<td width="10%">&nbsp;</td>
				</tr>
 				 <%
				al=CmnMgr.reverseRecords(htajus);
				for(int i=0; i<aj.size(); i++)
				{
				key = al.get(i).toString();
				CommonDataObject cdo3 = (CommonDataObject) htajus.get(key);
				String color = "TextRow01";
				if (i % 2 == 0) color = "TextRow02";

				%>

				<%=fb.hidden("key"+i,cdo3.getColValue("key"))%>
				<%=fb.hidden("empIdAj"+i,cdo3.getColValue("empId"))%>
				<%=fb.hidden("fechaAj"+i,cdo3.getColValue("fecha"))%>
				<%=fb.hidden("secuencia"+i,cdo3.getColValue("codigo"))%>
				<%=fb.hidden("chequeCreado"+i,cdo3.getColValue("imprimir"))%>
				<%=fb.hidden("periodo"+i,periodo)%>
				<%=fb.hidden("anio"+i,anio)%>
				<%=fb.hidden("mes"+i,mes)%>
				<%=fb.hidden("quincena"+i,quincena)%>
				<%=fb.hidden("cierre"+i,cierre)%>
				<%=fb.hidden("grupoSel"+i,grupo)%>
				<%=fb.hidden("desde"+i,desde)%>
				<%=fb.hidden("hasta"+i,hasta)%>
				<%=fb.hidden("emp_id"+i,cdo3.getColValue("emp_id"))%>
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("grupo"+i,cdo3.getColValue("grupo"))%>
				<%=fb.hidden("estado"+i,cdo3.getColValue("estado"))%>

				<tr class="TextRow01">
				<td><%=cdo3.getColValue("grupo")%></td>
				<td><%=cdo3.getColValue("numEmpleado")%></td>
				<td><%=cdo3.getColValue("nombre")%></td>
				<td><%=cdo3.getColValue("estado")%></td>

				<td align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,"onClick=\"javascript:verCheck()\"")%></td>

				</tr>
				<%
				}
				%>
			</table>
		</td>
	</tr>

	<tr class="TextRow01">
      <td align="right">Total Empl : <%=fb.textBox("cant",""+aj.size(),false,false,true,4)%> &nbsp;&nbsp;Total  Selec. : <%=fb.textBox("cont","",false,false,true,4)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
	  <% fb.appendJsValidation("if(error>0)doAction();"); %>

	<authtype type='50'>
	<tr class="TextRow02">
          <td align="center">
<authtype type='51'><%=fb.button("ejecutar","EJECUTAR",true,false,null,null,"onClick=\"javascript:procEjecutar();\"")%></authtype>

	 &nbsp;&nbsp;
	  <%=fb.button("eliminar","ELIMINAR",true,viewMode,null,null,"onClick=\"javascript:procEliminar();\"")%>



        </tr>
	</authtype>
<%=fb.formEnd(true)%>

<!-- =================  F O R M   E N D   H E R E   =============== -->
</table>


			</td>
		  </tr>
		</table>
	</td>
</tr>
</table>

<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
} //GET
else
{

String dl = "", sqlItem = "";
String baction 		= request.getParameter("baction");
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	al.clear();
	int	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("check"+i)!=null){
			cdo.addColValue("periodo", request.getParameter("periodo"));
			cdo.addColValue("anio", request.getParameter("anio"+i));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("estado", request.getParameter("estado"+i));
			cdo.addColValue("anioPago", request.getParameter("anio"+i));
			cdo.addColValue("quincenaPago", request.getParameter("periodo"+i));
			cdo.addColValue("fechaIni", request.getParameter("desde"+i));
			cdo.addColValue("fechaFin", request.getParameter("hasta"+i));
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("unidad", request.getParameter("grupo"+i));
			cdo.addColValue("usuario", (String) session.getAttribute("_userName"));

			al.add(cdo);
		}
	}

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		//VacMgr.distribuirSobretiempo(al);
		ConMgr.clearAppCtx(null);
		}
	if (request.getParameter("baction").equalsIgnoreCase("EJECUTAR")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		//VacMgr.distribuirSobretiempo(al);
		ConMgr.clearAppCtx(null);
	} else if (request.getParameter("baction").equalsIgnoreCase("ELIMINAR")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		//VacMgr.eliminaSobretiempo(al);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindowOld(){
<%
if (VacMgr.getErrCode().equals("1")){
%>
	alert('<%=VacMgr.getErrMsg()%>');
	parent.window.setValues();
<%
} else throw new Exception(VacMgr.getErrMsg());
%>
}




function closeWindow()
{
<%
if (VacMgr.getErrCode().equals("1"))
{
%>
	alert('<%=VacMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/proc_genera_sobretiempo_det.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/proc_genera_sobretiempo_det.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/proc_genera_sobretiempo_det.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(VacMgr.getErrMsg());
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
