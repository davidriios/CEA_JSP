<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCAUT" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCAUT" scope="session" class="java.util.Vector" />
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

CommonDataObject solCdo = new CommonDataObject();

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String id = (request.getParameter("id")==null?"0":request.getParameter("id"));
String sql = "";
String key = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = (request.getParameter("pacId")==null?"":request.getParameter("pacId"));
String admRoot = (request.getParameter("admRoot")==null?"":request.getParameter("admRoot"));
String compania = (String) session.getAttribute("_companyId");
String change = request.getParameter("change");
String cds = request.getParameter("cds");
boolean viewMode = false;
if (mode == null) mode = "add";
String estadoData = "";
String noAdmision = (request.getParameter("noAdmision")==null?"":request.getParameter("noAdmision"));
String fStyle = "none";
int hasSol = CmnMgr.getCount("select count(codigo) from tbl_adm_cargos_automaticos where estado in('T','P') and compania = "+compania+" and pac_id = "+pacId+" and admision_corte = "+admRoot);
if (request.getMethod().equalsIgnoreCase("GET"))
{



 if (pacId.trim().equals("") || noAdmision.trim().equals("")) throw new Exception("Por favor contacte un administrador [Paciente no encontrado]");

	if (change==null){

		  iCAUT.clear();
		  vCAUT.clear();

		  sql = "select decode(estado,'A','U','P','U','')action,decode(estado,'T',1,'P',1,'E',2,'D',3,'R',4)orden, codigo,pac_id,admision,estado,usuario_creacion,usuario_modificacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion,to_char(fecha_inicio,'dd/mm/yyyy')fecha_inicio, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion,cds,comentarios,to_char(fecha_fin,'dd/mm/yyyy') fecha_fin,to_char(fecha_ult_cargo,'dd/mm/yyyy hh12:mi:ss am'),validar_cargo, codigo_trx_ref,admision_corte,other1,other2,cod_ref, frecuencia_cargo, frecuencia_hora,generar_cargo,tipo_ref,decode(tipo_ref,'US',(select s.descripcion from tbl_sal_uso s where s.codigo = x.cod_ref and s.compania = x.compania),(select a.descripcion from tbl_inv_articulo a where a.cod_articulo = x.cod_ref and a.compania=x.compania  )  ) descItem ,decode(tipo_ref,'US',(select nvl(s.precio_venta,0) from tbl_sal_uso s where s.codigo = x.cod_ref and s.compania = x.compania),(select nvl(a.precio_venta,0) from tbl_inv_articulo a where a.cod_articulo = x.cod_ref and a.compania=x.compania  )  ) as uso_price,to_char(x.hora_inicio,'hh12:mi am') as hora_inicio from tbl_adm_cargos_automaticos x  where pac_id = "+pacId+" and admision_corte = "+admRoot+" and compania = "+compania+" order by 2 asc,fecha_creacion desc";

		  al = SQLMgr.getDataList(sql);

		  for (int i=0; i<al.size(); i++){
			CommonDataObject cdo = (CommonDataObject) al.get(i);

			cdo.setKey(i);
			cdo.setAction(cdo.getColValue("action"));

			try
			{
				iCAUT.put(cdo.getKey(), cdo);
				vCAUT.addElement(cdo.getColValue("codigo"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		 }
	} //change = null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Admision -  Cargos Automaticos- '+document.title;
function doAction(){<%if(hasSol>0){%>alert('HAY SOLICITUDES EN ESTADO:  TEMPORAL/PENDIENTE!!!!!');<%}%>checkFrec();}
function canSubmit(){return true;}
function _doSubmit(formName,bAction){setBAction(formName,bAction);if(form0Validation()){if(canSubmit()) document.form0.submit();}}
function checkSol(value,codItem)
{
 if(codItem =='0'){
var cantSol = getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_cargos_automaticos','pac_id=<%=pacId%> and admision=<%=noAdmision%> and estado in(\'T\',\'P\') and cat_equipo ='+value,''); if(parseInt(cantSol)>0)alert('Hay Solicitudes de equipo de la Categoria Seleccionada en estado TEMPORAL/PENDIENTE  = '+cantSol);}

}
function showUsoList(cInd){
  abrir_ventana("../common/check_uso.jsp?fp=adm_cargos_aut&curIndex="+cInd+"&id=<%=id%>")
}
function ctrlFrec(val,k){if (val=="H"){document.getElementById("frec"+k).style.display = "inline";document.getElementById("frecuencia_hora"+k).className = "FormDataObjectRequired";}else document.getElementById("frec"+k).style.display = "none";}
function checkFrec(){var  size = <%=iCAUT.size()%>;var x=0;for(i=0;i<size;i++){  var frecCargo = '';if(document.getElementById("frecuencia_cargo"+i))frecCargo=document.getElementById("frecuencia_cargo"+i).value;  var frecHora  = '';if(document.getElementById("frecuencia_hora"+i))frecHora= document.getElementById("frecuencia_hora"+i).value.trim();   if (frecCargo=="H" /*&& frecHora==''*/){	 document.getElementById("frecuencia_hora"+i).className = "FormDataObjectRequired";    if (frecCargo=="H" && frecHora=='')x++;  }  }  if(x>0){ alert("Por favor indique cada que hora se generará los cargos!");return false;}  else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION - TRANSACCIONES - CARGOS AUTOMATICOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
							<tr class="TextPanel">
								<td colspan="2">Paciente</td>
							</tr>
							<tr>
								<td colspan="2">
								   <jsp:include page="../common/paciente.jsp" flush="true">
										<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
										<jsp:param name="fp" value="expediente"></jsp:param>
										<jsp:param name="mode" value="view"></jsp:param>
										<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
									</jsp:include>
								</td>
							</tr>
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("EQMSize",""+iCAUT.size())%>
				<%=fb.hidden("admRoot",admRoot)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("codigo",id)%>
				<%=fb.hidden("cds",cds)%>
				<tr>
					<td colspan="2">
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow02"><td colspan="10">&nbsp;</td></tr>
							<tr class="TextPanel">
								<td colspan="10">Solicitud de Cargos automaticos</td>
							</tr>

							<tr class="TextPanel">
								<td width="4%">No.</td>
								<td width="5%">Tipo</td>
								<td width="15%">Descripcion</td>
								<td width="6%">Precio</td>
								<td width="10%">Frecuencia del Cargo</td>
								<td width="10%">Fecha Inicio</td>
								<td width="10%">Fecha Fin</td>
								<td width="33%">Comentario</td>
								<td width="5%">Estado</td>
								<td width="2%"><%=fb.submit("btnaddSol","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Solicitud")%>&nbsp;</td>
							</tr>




						<%
						al = CmnMgr.reverseRecords(iCAUT);
						for (int i=0; i<iCAUT.size(); i++)
						{
						  key = al.get(i).toString();
						  CommonDataObject cdo = (CommonDataObject) iCAUT.get(key);
						  String display = " style='display:none;'";
						  boolean modeViewReg = false;
						  estadoData  = "";
						  //if (cdo.getColValue("estado").equals("E")||cdo.getColValue("estado").equals("R")||cdo.getColValue("estado").equals("C")||cdo.getColValue("estado").equals("D")){estadoData += ",E=ENTREGADO,R=RECIBIDO,C=CANCELADO,D=DEVUELTO";modeViewReg=true;}
						  //else if (cdo.getColValue("estado").equals("C"))estadoData = ",C=CA";
						  if (cdo.getColValue("codigo").equals("0")) estadoData += "A=ACTIVO"; else if (!cdo.getColValue("codigo").equals("0")&&(cdo.getColValue("estado").equals("P")||cdo.getColValue("estado").equals("F")||cdo.getColValue("estado").equals("A"))) estadoData = "A=ACTIVO,P=EN PROCESO,I=INACTIVO";
						  else if (!cdo.getColValue("codigo").equals("0")&&(cdo.getColValue("estado").equals("I")))estadoData = "I=INACTIVO";
if(cdo.getColValue("frecuencia_cargo")!=null && cdo.getColValue("frecuencia_cargo").trim().equals("H"))fStyle="";
else fStyle = "none";
						%>

						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%=fb.hidden("id"+i,cdo.getColValue("codigo"))%>
						<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
						<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
						<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
						<%=fb.hidden("cds"+i,cdo.getColValue("cds"))%>
						<%=fb.hidden("other1"+i,cdo.getColValue("other1"))%>
						<%=fb.hidden("other2"+i,cdo.getColValue("other2"))%>
						<%=fb.hidden("validar_cargo"+i,cdo.getColValue("validar_cargo"))%>
						<%=fb.hidden("codigo_trx_ref"+i,cdo.getColValue("codigo_trx_ref"))%>

						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						    <tr class="TextRow01">
								<td><%=fb.textBox("codigo"+i,cdo.getColValue("codigo"),false,false,true,5,5,null,null,"")%></td>
								<td><%=fb.select("tipo_ref"+i,"US=Usos",cdo.getColValue("tipo_ref"),false,(cdo.getColValue("cod_ref")!=null &&!cdo.getColValue("cod_ref").equals("")),0,"Text10","","")%></td>
								<td><%=fb.textBox("cod_ref"+i,cdo.getColValue("cod_ref"),true,false,true,2,"Text10","","")%>
							   <%=fb.textBox("descItem"+i,cdo.getColValue("descItem"),false,false,true,20,"Text10",null,"")%>
								<%=fb.button("btnUso"+i,"...",false,false,null,null,"onClick=\"javascript:showUsoList("+i+")\"")%></td>
								<td><%=fb.decBox("uso_price"+i,cdo.getColValue("uso_price"),false,false,true,10,"Text10",null,"")%></td>
								<td><%=fb.select("frecuencia_cargo"+i, "D=DIARIA (24 HORAS),H=POR HORA",cdo.getColValue("frecuencia_cargo"),false,false,0,null,null,"onchange=ctrlFrec(this.value,"+i+")")%>
						<span id="frec<%=i%>" style="display:<%=fStyle%>">&nbsp;&nbsp;Cada <%=fb.intBox("frecuencia_hora"+i,cdo.getColValue("frecuencia_hora"),false,false,false,2,2)%>
						</span>
						<%=fb.select("generar_cargo"+i, "I=AL INICIO,F=AL FINAL",cdo.getColValue("generar_cargo"),false,false,0,null,null,"")%></td>

						<td><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="<%="fecha_inicio"+i%>" />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_inicio")%>" />
									<jsp:param name="format" value="dd/mm/yyyy" />
									<jsp:param name="fieldClass" value="FormDataObjectRequired"/>
									<jsp:param name="readonly" value="<%=(viewMode||modeViewReg)?"y":"n"%>" />
								</jsp:include><br>
								 <jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="clearOption" value="true"/>
									<jsp:param name="nameOfTBox1" value="<%="hora_inicio"+i%>"/>
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_inicio")%>"/>
									<jsp:param name="format" value="hh12:mi am"/>
									<jsp:param name="fieldClass" value="FormDataObjectRequired"/>
									<jsp:param name="buttonClass" value="Text10"/>
									<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
								</jsp:include>


								</td>
								<td><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="<%="fecha_fin"+i%>" />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_fin")%>" />
									<jsp:param name="format" value="dd/mm/yyyy" />
									<jsp:param name="readonly" value="<%=(viewMode||modeViewReg)?"y":"n"%>" />
								</jsp:include></td>

								<td><%=fb.textarea("comentarios"+i,cdo.getColValue("comentarios"),true,false,(viewMode||modeViewReg),100,2,1000,"","width:100%","")%></td>
								<td><%=fb.select("estado"+i,estadoData,cdo.getColValue("estado"),false,(viewMode||modeViewReg),0,"","Text10","")%></td>
								<td>&nbsp;<%=(cdo.getAction().equalsIgnoreCase("I"))?fb.submit("rem"+i,"X",true,(viewMode||modeViewReg),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Solicitud"):""%></td>
							</tr>
						<%
						} // not deleting
						} //for
						%>



				<tr class="TextRow02">
					<td align="right" colspan="10">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.button("send","Guardar",true,viewMode,null,null,"onClick=\"javascript:_doSubmit('"+fb.getFormName()+"',this.value)\"")%>
						<%//=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<%fb.appendJsValidation("if(error==0){if(!checkFrec())error++;}");%>
				<%=fb.formEnd(true)%>

		</table>

	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
		String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
		String baction = request.getParameter("baction");

		int size = 0;
		if (request.getParameter("EQMSize") != null) size = Integer.parseInt(request.getParameter("EQMSize"));
		String itemRemoved = "";

		al.clear();
		iCAUT.clear();
		vCAUT.clear();
		int lineNo = 0;

		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_cargos_automaticos");
			cdo.setWhereClause("compania = "+compania+" and codigo = "+request.getParameter("id"+i));
			if(request.getParameter("id"+i).trim().equals("0"))
			{
				cdo.setAutoIncCol("codigo");
				cdo.addPkColValue("codigo","");
			}
			cdo.addColValue("codigo",request.getParameter("id"+i));
			cdo.addColValue("pac_id",request.getParameter("pacId"));
			cdo.addColValue("compania",compania);
			cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("admision",request.getParameter("admision"+i));
			cdo.addColValue("admision_corte",request.getParameter("admRoot"));
			cdo.addColValue("comentarios",request.getParameter("comentarios"+i));
			cdo.addColValue("cds",request.getParameter("cds"+i));
			cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
			cdo.addColValue("fecha_modificacion",cDate);
			cdo.addColValue("fecha_inicio",request.getParameter("fecha_inicio"+i));
			cdo.addColValue("hora_inicio",request.getParameter("hora_inicio"+i));
			cdo.addColValue("fecha_fin",request.getParameter("fecha_fin"+i));
			cdo.addColValue("other1",request.getParameter("other1"+i));
			cdo.addColValue("other2",request.getParameter("other2"+i));
			cdo.addColValue("validar_cargo",request.getParameter("validar_cargo"+i));

			cdo.addColValue("codigo_trx_ref",request.getParameter("codigo_trx_ref"+i));
			cdo.addColValue("tipo_ref",request.getParameter("tipo_ref"+i));
			cdo.addColValue("cod_ref",request.getParameter("cod_ref"+i));

			cdo.addColValue("descItem",request.getParameter("descItem"+i));
			cdo.addColValue("uso_price",request.getParameter("uso_price"+i));
			cdo.addColValue("frecuencia_cargo",request.getParameter("frecuencia_cargo"+i));
			cdo.addColValue("generar_cargo",request.getParameter("generar_cargo"+i));

			if (request.getParameter("frecuencia_cargo"+i) == null ||request.getParameter("frecuencia_cargo"+i).trim().equals("") || request.getParameter("frecuencia_cargo"+i).equals("D")) cdo.addColValue("frecuencia_hora","");
			else cdo.addColValue("frecuencia_hora",request.getParameter("frecuencia_hora"+i));



			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					iCAUT.put(cdo.getKey(),cdo);
					vCAUT.add(cdo.getColValue("codigo"));
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode=edit&id="+id+"&cds="+cds+"&pacId="+pacId+"&admRoot="+admRoot+"&noAdmision="+noAdmision);
			return;
		}


		if (baction != null && baction.equals("+"))
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("codigo","0");
			cdo.addColValue("pac_id",pacId);
			cdo.addColValue("admision",noAdmision);
			cdo.addColValue("admision_corte",admRoot);
			cdo.addColValue("validar_cargo","S");
			cdo.addColValue("cds",cds);
			cdo.addColValue("estado","P");
			cdo.addColValue("comentarios","");
			cdo.addColValue("fecha_creacion",cDate);
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion",cDate);
			cdo.addColValue("fecha_inicio",""+cDate.substring(0,10));
			cdo.addColValue("hora_inicio","");
			cdo.addColValue("fecha_fin","");

			cdo.setAction("I");
			cdo.setKey(iCAUT.size()+1);

			iCAUT.put(cdo.getKey(),cdo);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode=edit&id="+id+"&cds="+cds+"&pacId="+pacId+"&admRoot="+admRoot+"&noAdmision="+noAdmision);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_adm_cargos_automaticos");
			cdo.setWhereClause("codigo = '"+id+"' and compania = "+compania);
			cdo.setAction("I");
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&pacId=<%=pacId%>&admRoot=<%=admRoot%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>