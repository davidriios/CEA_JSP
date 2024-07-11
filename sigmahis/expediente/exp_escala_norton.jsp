<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.EscalaNorton"%>
<%@ page import="issi.expediente.DetalleEscalaNorton"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ECMgr" scope="page" class="issi.expediente.EscalaNortonMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ECMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
EscalaNorton en = new EscalaNorton();

boolean viewMode = false;
boolean checkDefault = false;

int rowCount = 0;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha = request.getParameter("fecha");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String subTitle="ESCALA DE NORTON";
String key = "";
int size = 0;
int ValorLabel=0;  //Roberto

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String cTime = CmnMgr.getCurrentDate("hh12:mi am");
if (fecha == null) fecha = cDate;
if (fg == null) fg = "NO";
if (mode == null || mode.trim().equals("")) mode = "add";
if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (id == null || id.trim().equals("")) id = "0";

if (mode.equalsIgnoreCase("view")||modeSec.equalsIgnoreCase("view")) viewMode = true;
/*if (CmnMgr.getCount("select count(*) from tbl_sal_escala_norton where pac_id  = "+pacId+" and secuencia = "+noAdmision+" and to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+fecha+"','dd/mm/yyyy')") == 0){
if (!viewMode) mode = "add";
}else
{if(!viewMode || fecha.trim().equals(cDate))
{ 	mode ="edit"; viewMode = false;}}
*/

if((fecha.trim().equals(cDate) && !id.trim().equals("0") ))
{ 	modeSec ="edit"; if(!mode.equalsIgnoreCase("view"))viewMode = false;}

if (fg.equalsIgnoreCase("BR")) subTitle = "ESCALA DE BRADEN";
else if (fg.equalsIgnoreCase("SG")) subTitle = "ESCALA SUSAN GIVENS";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
		
		sql=" select  to_char(fecha,'dd/mm/yyyy')fecha, total,id from tbl_sal_escala_norton where pac_id  = "+pacId+" and secuencia =  "+noAdmision+" and tipo = '"+fg+"' order by to_date(fecha,'dd/mm/yyyy') desc ";
		al3 = SQLMgr.getDataList(sql);

		if(!modeSec.trim().equals("add"))
		{	
			
		sql="select to_char(fecha,'dd/mm/yyyy') fecha, observacion, total ,to_char(hora,'hh12:mi:ss am')hora from tbl_sal_escala_norton where pac_id= "+pacId+" and secuencia= "+noAdmision+" and  id = "+id+" /* and  fecha(+)=to_date('"+fecha+"','dd/mm/yyyy')*/ ";
		en = (EscalaNorton) sbb.getSingleRowBean(ConMgr.getConnection(), sql, EscalaNorton.class);
		//System.out.println("Sql :: == "+sql);

			if (en == null)
			{
				en = new EscalaNorton();
				en.setFecha(fecha);
				en.setHora(cTime);
			}
		}else
		{
			en.setFecha(fecha);
		}



		sql=" select distinct a.codigo, a.descripcion,b.observacion from tbl_sal_concepto_norton a, tbl_sal_det_escala_norton b where a.tipo ='"+fg+"' and estado = 'A' and  a.codigo = b.cod_concepto(+) and  b.id(+)="+id+"/*and b.fecha(+)=to_date('"+fecha+"','dd/mm/yyyy')*/ order by a.codigo asc ";
System.out.println("Sql :: == "+sql);
		al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleEscalaNorton.class);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = '<%=subTitle%> - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();checkViewMode();}
function sumaEscala(){var total = 0;for (i=1;i<=parseInt(document.getElementById("size").value);i++){total = total + parseInt(document.getElementById("valor"+i).value);document.getElementById("total").value = total;document.getElementById("total2").value = total;<%if(fg.trim().equals("NO")){%>if (total >= 0 &&total<=12){document.getElementById("clasificacion").style.color='red';document.getElementById("clasificacion").innerHTML='ALTO RIESGO';document.getElementById("clasificacion2").style.color='red';document.getElementById("clasificacion2").innerHTML='ALTO RIESGO';}else if (total>=13&&total<=15){document.getElementById("clasificacion").style.color='orange';document.getElementById("clasificacion").innerHTML='PRECAUCION';document.getElementById("clasificacion2").style.color='orange';document.getElementById("clasificacion2").innerHTML='PRECAUCION';}else if (total>=16){document.getElementById("clasificacion").style.color='green';document.getElementById("clasificacion").innerHTML='NORMAL';document.getElementById("clasificacion2").style.color='green';document.getElementById("clasificacion2").innerHTML='NORMAL';}<%}else if(fg.trim().equals("BR")){%>if (total<=12){document.getElementById("clasificacion").style.color='red';document.getElementById("clasificacion").innerHTML='ELEVADO RIESGO';document.getElementById("clasificacion2").style.color='red';document.getElementById("clasificacion2").innerHTML='ELEVADO RIESGO';}else if (total>=13&&total<=14){document.getElementById("clasificacion").style.color='orange';document.getElementById("clasificacion").innerHTML='MODERADO RIESGO';document.getElementById("clasificacion2").style.color='orange';document.getElementById("clasificacion2").innerHTML='MODERADO RIESGO';}else if (total>=15&&total<=16){document.getElementById("clasificacion").style.color='green';document.getElementById("clasificacion").innerHTML='BAJO RIESGO';document.getElementById("clasificacion2").style.color='green';document.getElementById("clasificacion2").innerHTML='BAJO RIESGO';}else if (total>=16){document.getElementById("clasificacion").style.color='blue';document.getElementById("clasificacion").innerHTML='NORMAL';document.getElementById("clasificacion2").style.color='blue';document.getElementById("clasificacion2").innerHTML='NORMAL';}<%}else  if(fg.trim().equals("SG")){%>if (total>=0&&total<=5){document.getElementById("clasificacion").style.color='blue';document.getElementById("clasificacion").innerHTML='NORMAL';document.getElementById("clasificacion2").style.color='blue';document.getElementById("clasificacion2").innerHTML='NORMAL';}else if (total>=6){document.getElementById("clasificacion").style.color='orange';document.getElementById("clasificacion").innerHTML='PRECAUCION';document.getElementById("clasificacion2").style.color='orange';document.getElementById("clasificacion2").innerHTML='PRECAUCION';}<%}%>}}
function checkValor(x,y,z){document.getElementById("valor"+x).value = y;document.getElementById("cod_subconcepto"+x).value = z;sumaEscala();}
function verEscala(k){var fecha_e = eval('document.form0.fecha'+k).value ;var id = eval('document.form0.idx'+k).value ;window.location = '../expediente/exp_escala_norton.jsp?mode=<%=mode%>&modeSec=view&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id='+id+'&fecha='+fecha_e+"&desc=<%=desc%>";}
function add(){window.location = '../expediente/exp_escala_norton.jsp?mode=<%=mode%>&modeSec=add&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=0&desc=<%=desc%>';}
function printEscala(){var fecha = document.form0.fecha.value;abrir_ventana1('../expediente/print_escala_norton.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fg=<%=fg%>&id=<%=id%>&desc=<%=desc%>&fechaEscala='+fecha);}
function printEscalaTodo(){var fecha = document.form0.fecha.value;abrir_ventana1('../expediente/print_escala_norton.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->



<table width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("modeSec",modeSec)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("medSize","")%>
			<%=fb.hidden("medLastLineNo","")%>
			<%=fb.hidden("id",""+id)%>
			<%=fb.hidden("fg",""+fg)%>
            <%=fb.hidden("desc",desc)%>
			<tr class="TextRow01">
					<td colspan="3" align="right"> 
					<%if(!mode.equals("view")){%>
					<a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Agregar</cellbytelabel> ]</a>
					<%}%>
					&nbsp;&nbsp;<!---</td>
			<td colspan="3" align="right">---> <!--<a href="javascript:printEscalaTodo()" class="Link00">[ Imprimir Todo]</a>&nbsp; ---><a href="javascript:printEscala()" class="Link00">[ <cellbytelabel id="2">Imprimir</cellbytelabel> ]</a>&nbsp;&nbsp;</td>
			</tr>
			<tr>
					<td  colspan="3" style="text-decoration:none;">
					<div id="listado" width="100%" class="exp h100">
					<div id="detListado" width="98%" class="child">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td colspan="2">&nbsp;<cellbytelabel id="3">Listado de Evaluaciones</cellbytelabel></td>
						</tr>

						<tr class="TextHeader" align="center">
							<td width="30%"><cellbytelabel id="4">Fecha</cellbytelabel></td>
							<td width="70%"><cellbytelabel id="5">Total</cellbytelabel></td>
						</tr>

<%

for (int i=1; i<=al3.size(); i++)
{
	cdo = (CommonDataObject) al3.get(i-1);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>

		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("idx"+i,cdo.getColValue("id"))%>


		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:verEscala(<%=i%>)" >
				<td><%=cdo.getColValue("fecha")%></td>
				<td><%=cdo.getColValue("total")%></td>

		</tr>
<%
}
%>
						</table>
						</div>
						</div>
					</td>
				</tr>

			<tr class="TextRow02">
				<td colspan="3">
				<table border="0" cellpadding="0" cellspacing="0" class="TextRow02" width="100%">
					<tr>
						<td><cellbytelabel id="4">Fecha</cellbytelabel>:&nbsp;
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fecha" />
							<jsp:param name="valueOfTBox1" value="<%=en.getFecha()%>" />
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
							</jsp:include> <cellbytelabel id="6">Hora</cellbytelabel>
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="hora" />
							<jsp:param name="valueOfTBox1" value="<%=(en.getHora()!=null?en.getHora():"")%>" />
							<jsp:param name="format" value="hh12:mi:ss am"/>
							<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
							</jsp:include></td>
					</tr>
					<tr>
						<td><cellbytelabel id="7">Observaci&oacute;n</cellbytelabel><%=fb.textarea("observacion",en.getObservacion(),false,false,viewMode,70,2,2000,null,"",null)%></td>
					</tr>
				</table></td>
				</tr>
			<tr class="TextRow02">
				<td>&nbsp;</td>
				<td align="right"><cellbytelabel id="5">Total</cellbytelabel>:<%=fb.textBox("total","",false,false,true,5)%></td>
				<td><b><label id="clasificacion" style="color:green">HOLA</label></b></td>

		</tr>
			<tr class="TextHeader" align="center">
				<td width="20%"><cellbytelabel id="8">Factor a Evaluar</cellbytelabel></td>
				<td width="20%"><cellbytelabel id="9">Escala</cellbytelabel></td>
				<td width="25%"><cellbytelabel id="10">Observaci&oacute;n</cellbytelabel></td>
		</tr>
		<%if(fg.trim().equals("SG")){%>
		<tr class="TextHeader">
				<td colspan="3"><cellbytelabel id="11">SIGNOS CONDUCTUALES</cellbytelabel></td>
		</tr>
		<%}%>
		
		<tr class="TextRow01">
				<td colspan="3">
		<div id="listado2" width="100%" class="exp h350">
					<div id="detListado2" width="98%" class="child">
				<table width="100%" cellpadding="1" cellspacing="0">
<%
			
		//al = CmnMgr.reverseRecords(HashDet);
		for (int i = 1; i <= al.size(); i++)
		{
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";

		key = al.get(i - 1).toString();
		DetalleEscalaNorton co = (DetalleEscalaNorton) al.get(i - 1);
		////System.out.println("=========== Descripcion: "+i+" "+co.getDescripcion()+"===============");


%>
			<%=fb.hidden("key"+i,key)%>
		<%if(fg.trim().equals("SG")&& i==7){%>
		<tr class="TextHeader">
				<td colspan="3"><cellbytelabel id="12">SIGNOS FISIOL&Oacute;GICOS</cellbytelabel></td>
		</tr>
		<%}%>
			<tr class="<%=color%>">
				<td align="left" width="20%"><%=co.getDescripcion()%></td>
				<td width="20%">
<!-- ======================================= INICIO LOOP ESCALA  ================================================ -->
				<table width="100%" border="0" cellpadding="0" cellspacing="0" class="<%=color%>">
				<%
					sql = "select b.observacion,a.codigo,a.descripcion,a.secuencia,a.valor,nvl(b.valor,-1) as escala from tbl_sal_det_escala_norton b, tbl_sal_det_concepto_norton a where  a.codigo = b.COD_CONCEPTO(+) and a.secuencia = b.COD_SUBCONCEPTO(+) and a.tipo = '"+fg+"' and a.estado ='A' and a.codigo="+co.getCodigo()+" and b.id(+)= "+id+" /*and b.pac_id(+)="+pacId+" AND b.fecha(+)=to_date('"+fecha+"','dd/mm/yyyy')*/ ORDER BY a.valor DESC ";
					al2 = SQLMgr.getDataList(sql);
					String cod_subconcepto = "";
					String valor = "";
					for (int j=0; j<al2.size(); j++){
					cdo = (CommonDataObject) al2.get(j);

					if(j==0){

					cod_subconcepto = cdo.getColValue("secuencia");
					if (viewMode)
					{
						checkDefault=false;
						valor = cdo.getColValue("escala");
					}else
					{

						/*if(fg.equalsIgnoreCase("SG"))checkDefault=false;
						else */checkDefault=true;
						valor = cdo.getColValue("valor");
					}

					} else { checkDefault=false; }

					if(cdo.getColValue("escala").equalsIgnoreCase(cdo.getColValue("valor"))){
					checkDefault=true;
					cod_subconcepto = cdo.getColValue("secuencia");
					valor = cdo.getColValue("valor");
					}

				if(valor.equalsIgnoreCase("-1"))valor="0";

				%>
					<tr>
						<td width="5%" valign="top" >
						<%=fb.radio("secuencia"+i, cdo.getColValue("valor"), checkDefault, viewMode, false, "", "", "onClick=\"javascript:checkValor('"+i+"','"+cdo.getColValue("valor")+"','"+cdo.getColValue("secuencia")+"')  \" ")%></td>
						<td valign="top"><%=cdo.getColValue("descripcion")%></td>
						<td width="5%" align="right" valign="top"><%=cdo.getColValue("valor")%></td>
					</tr>
				<% } %>
				</table>

				<%=fb.hidden("cod_concepto"+i,co.getCodigo())%>
				<%=fb.hidden("cod_subconcepto"+i,cod_subconcepto)%>
				<%=fb.hidden("valor"+i,valor)%>

<!-- ======================================= FIN LOOP ESCALA  ================================================ --></td>
				<td width="25%"><%=fb.textarea("observacion"+i,co.getObservacion(),false,false,viewMode,50,3,2000,null,"width='100%'",null)%></td>
				</tr>
<%
}
%>
				</table>				
			</div>
		</div>
	</td>
</tr>

			<tr class="TextRow02">
				<td>&nbsp;</td>
				<td align="right"><cellbytelabel id="5">Total</cellbytelabel>:<%=fb.textBox("total2","",false,false,true,5)%></td>
				<td><b><label id="clasificacion2" style="color:green">HOLA</label></b></td>

				</tr>

			<tr class="TextRow02" >
				<td colspan="3" align="right">
				<cellbytelabel id="13">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="14">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="15">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
				</td>
			</tr>
			<%=fb.formEnd(true)%>
			<script type="text/javascript">sumaEscala();</script>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//fin GET
else
{
	
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	size = Integer.parseInt(request.getParameter("size"));
	fecha = request.getParameter("fecha");
	ArrayList list = new ArrayList();

	EscalaNorton eno = new EscalaNorton();
	//eno.setCodigoPaciente(request.getParameter("codPac"));
	//eno.setFechaNacimiento(request.getParameter("dob"));
	eno.setSecuencia(request.getParameter("noAdmision"));
	eno.setFecha(request.getParameter("fecha"));
	eno.setHora(request.getParameter("hora"));
	eno.setPacId(request.getParameter("pacId"));
	eno.setId(request.getParameter("id"));
	eno.setTipo(request.getParameter("fg"));
	
	eno.setFechaCreacion(cDateTime);
	eno.setFechaModificacion(cDateTime);
	eno.setUsuarioCreacion((String) session.getAttribute("_userName"));
	eno.setUsuarioModificacion((String) session.getAttribute("_userName"));
	eno.setTotal(request.getParameter("total"));
	eno.setObservacion(request.getParameter("observacion"));

HashDet.clear();
for (int i=1; i<=size; i++)
{
			DetalleEscalaNorton dre = new DetalleEscalaNorton();

			//dre.setFechaNacimiento(request.getParameter("dob"));
			//dre.setCodigoPaciente(request.getParameter("codPac"));
			//dre.setSecuencia(request.getParameter("noAdmision"));
			//dre.setFecha(request.getParameter("fecha"));
			dre.setCodConcepto(request.getParameter("cod_concepto"+i));
			dre.setCodSubconcepto(request.getParameter("cod_subconcepto"+i));
			dre.setValor(request.getParameter("valor"+i));
			dre.setAplicar("S");
			//dre.setPacId(request.getParameter("pacId"));
			dre.setObservacion(request.getParameter("observacion"+i));

			try {
			HashDet.put(request.getParameter("key"+i), dre);
			}
			catch(Exception e)
			{ System.err.println(e.getMessage()); }

			list.add(dre);
}
	eno.setDetalleEscalaNorton(list);
	if (modeSec.equalsIgnoreCase("add"))
	{
		ECMgr.add(eno);
		id = ECMgr.getPkColValue("id");
	}
	else if (modeSec.equalsIgnoreCase("edit"))
	{
		id = request.getParameter("id");
		ECMgr.update(eno);
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ECMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ECMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/exp_escala_norton.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/exp_escala_norton.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%	} %>
<%
	if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(ECMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&mode=<%=mode%>&modeSec=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha=<%=fecha%>&id=<%=id%>&fg=<%=fg%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

