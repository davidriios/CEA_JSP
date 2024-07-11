<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
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
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iValoresCriticos" scope="session" class="java.util.Hashtable" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String compania = (String) session.getAttribute("_companyId");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (cds == null) cds = "";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fechaCreacion = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String key = "";
ArrayList alValCr = new ArrayList();
ArrayList alValCrAll = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	
	sbSql.append("select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_cds_val_criticos");
	if (!viewMode) sbSql.append(" where estado = 'A'"); /*and cds = "+cds+"*/
	sbSql.append(" order by 2");
	alValCr = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	alValCrAll = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_cds_val_criticos order by 2",CommonDataObject.class);

	if(change == null){ 

		iValoresCriticos.clear();

		sbSql = new StringBuffer();
		sbSql.append("select v.secuencia, v.pac_id, v.admision, v.observacion, v.codigo_valor, v.valor, to_char(v.fecha_creacion,'dd/mm/yyyy hh12:mi am') fecha_creacion from tbl_sal_val_criticos v where v.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and v.admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" order by v.fecha_creacion");
		
		al = SQLMgr.getDataList(sbSql.toString());
		
		for (int i=0; i<al.size(); i++){
			cdo = (CommonDataObject) al.get(i);

			cdo.setKey(i);
			cdo.setAction("U");

			try
			{
				iValoresCriticos.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		
		if (al.size() == 0){
			cdo = new CommonDataObject();
			cdo.addColValue("secuencia","0");

			cdo.setKey(iValoresCriticos.size()+1);
			cdo.setAction("I");
			cdo.addColValue("fecha_creacion",fechaCreacion);

			try
			{
				iValoresCriticos.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//change
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>

<script>
document.title = 'EXPEDIENTE - VALORES CRITICOS '+document.title;
function doAction(){newHeight();}

function imprimir(){
	abrir_ventana1('../expediente/print_valores_criticos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');
}

function isAvalidNoRec(){
   var s = parseInt("<%=iValoresCriticos.size()%>",10);
   for (var i=0;i<s; i++){
     var fecha = $("#fecha"+i).val();
     var codValor = $("#codigo_valor"+i).val();
     var valor = $("#valor"+i).val();
	 var action = $("#action"+i).val();
	 var flag = true;
	 if ("I" == action){
		 var existed = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_val_criticos',"pac_id=<%=pacId%> and admision = <%=noAdmision%> and codigo_valor="+codValor+" and valor = '"+valor+"' and fecha_creacion = to_date('"+fecha+"','dd/mm/yyyy hh12:mi am')",''));
		 
		 if (existed){
		  alert("Esta tratando de registrar valores duplicados! ");
		 
		  $("#row"+i).each(function() {
			$.each(this.cells, function(){
				$(this).css({border:"red solid 2px"})
				debug($(this));
			});
		  });
		  flag = false;
		  break;
		 }
	 }
   }
   return flag;
 
 
  
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr class="TextRow01">
		<td colspan="4" align="right"> <a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a></td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
			 <%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			 <%=fb.formStart(true)%>
			 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			 <%=fb.hidden("baction","")%>
			 <%=fb.hidden("mode",mode)%>
			 <%=fb.hidden("modeSec",modeSec)%>
			 <%=fb.hidden("seccion",seccion)%>
			 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
			 <%=fb.hidden("dob","")%>
			 <%=fb.hidden("codPac","")%>
			 <%=fb.hidden("pacId",pacId)%>
			 <%=fb.hidden("noAdmision",noAdmision)%>
			 <%=fb.hidden("tab","2")%>
			 <%=fb.hidden("vcSize",""+iValoresCriticos.size())%>
			 <%=fb.hidden("cds",""+cds)%>
			 <%=fb.hidden("desc",""+desc)%>
			 <%fb.appendJsValidation("if(isAvalidNoRec()==false){error++;}");%>
			 <tr class="TextHeader" >
				<td colspan="5"><cellbytelabel id="13">VALORES CR&Iacute;TICOS</cellbytelabel></td>
			 </tr>
			 <tr class="TextHeader">
				<td width="25%" class="Text10" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
				<td width="25%" class="Text10" align="center"><cellbytelabel>Prueba</cellbytelabel></td>
				<td width="22%" class="Text10" align="center"><cellbytelabel>Valor Cr&iacute;tico</cellbytelabel></td>
				<td width="25%" class="Text10"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
				<td width="3%">
				<%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Valores Críticos")%>
				</td>
			 </tr>
					
			 <%
			    String form = "'"+fb.getFormName()+"'";
				al.clear();
				al = CmnMgr.reverseRecords(iValoresCriticos);

				for (int i = 0; i <iValoresCriticos.size(); i++){
					 String color = "TextRow01";
					 if (i % 2 == 0) color = "TextRow02";

					 key = al.get(i).toString();
					 cdo = (CommonDataObject) iValoresCriticos.get(key);
			 %>
					 <%=fb.hidden("remove"+i,"")%>
					 <%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
					 <%=fb.hidden("action"+i,cdo.getAction())%>
					 <%=fb.hidden("key"+i,cdo.getKey())%>
					 
					 <tr class="<%=color%>" align="center" id="row<%=i%>">
						<td>

							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
							<jsp:param name="format" value="dd/mm/yyyy hh12:mi am" />
							<jsp:param name="hintText" value="01/01/2014 01:01 am" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_creacion")%>" />
							<jsp:param name="readonly" value="<%=(cdo.getAction().equals("U"))?"y":"n"%>"/>
						  </jsp:include>
						</td>
						<td><%=fb.select("codigo_valor"+i,cdo.getAction().equals("U")?alValCrAll:alValCr,cdo.getColValue("codigo_valor"),false,cdo.getAction().equals("U"),0,"","width:200px","","","")%></td>
						<td><%=fb.textBox("valor"+i,cdo.getColValue("valor"),true,false,cdo.getAction().equals("U"),23,500,"",null,null)%></td>
						<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,false,25,2,1000,"",null,null)%></td>
						<td><%=fb.submit("rem"+i,"X",true,(cdo.getAction().equals("U")),null,null,"onClick=\"javascript:removeItem("+form+","+i+")\"","Eliminar")%></td>
					</tr>
				<%}%>
				
				
				<tr class="TextRow02">
					<td colspan="6" align="right">
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
					</td>
				</tr>
				<%fb.appendJsValidation("if(error>0)newHeight();");%>
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
	String itemRemoved = "";
 	
	int size = 0;
	al.clear();
	iValoresCriticos.clear();
	if (request.getParameter("vcSize") != null) size = Integer.parseInt(request.getParameter("vcSize"));

	for (int i=0; i<size; i++){
		CommonDataObject cdo2 = new CommonDataObject();
		cdo2.setTableName("tbl_sal_val_criticos");
		cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and codigo_valor="+request.getParameter("codigo_valor"+i)+" and secuencia="+request.getParameter("secuencia"+i));
		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));
		cdo2.addColValue("codigo_valor",request.getParameter("codigo_valor"+i));
		cdo2.addColValue("valor",request.getParameter("valor"+i));
		cdo2.addColValue("observacion",request.getParameter("observacion"+i));
		cdo2.addColValue("compania",compania);
		
		cdo2.addColValue("fecha_creacion",request.getParameter("fecha"+i));
		cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo2.addColValue("fecha_modificacion",cDateTime);
		
		if (request.getParameter("secuencia"+i)==null || ( request.getParameter("secuencia"+i).trim().equals("0")||request.getParameter("secuencia"+i).trim().equals("")))
		{
			cdo2.setAutoIncCol("secuencia");
			cdo2.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			//cdo2.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));		
		}else cdo2.addColValue("secuencia",request.getParameter("secuencia"+i));
		
		cdo2.setAction(request.getParameter("action"+i));
		cdo2.setKey(i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
			itemRemoved = cdo2.getKey();
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");
			else cdo2.setAction("D");
		}

		if (!cdo2.getAction().equalsIgnoreCase("X")){
			try
			{
				iValoresCriticos.put(cdo2.getKey(),cdo2);
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//for
	
	
	if(!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc);
			return;
	}
	
	if(baction.equals("+"))//Agregar
	{
		CommonDataObject cdo2 = new CommonDataObject();

		cdo2.addColValue("secuencia","0");
		cdo2.addColValue("fecha_creacion",fechaCreacion);
		cdo2.setAction("I");
		cdo2.setKey(iValoresCriticos.size()+1);
		
		System.out.println("::::::::::::::::::::::::::::::::::::::: fechaCreacion = "+fechaCreacion);

		try
		{
			iValoresCriticos.put(cdo2.getKey(),cdo2);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc);
		return;
	}
		
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();

			cdo3.setTableName("tbl_sal_val_criticos");
			cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
			cdo3.setAction("I");
			al.add(cdo3);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&cds=<%=cds%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
<%
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
