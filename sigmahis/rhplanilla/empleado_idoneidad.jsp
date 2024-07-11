<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htIdoneidad"  scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vIdoneidad"   scope="session" class="java.util.Vector"/>

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
boolean viewMode = false;
String key = "";
String change = request.getParameter("change");
String fp =request.getParameter("fp");
String fg =request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");
String mode = request.getParameter("mode");
String prov = request.getParameter("prov");
String sig  = request.getParameter("sig");
String tom  = request.getParameter("tom");
String asi  = request.getParameter("asi");
String tab  = request.getParameter("tab");
String id   = request.getParameter("id");
String anio = request.getParameter("anio");
String cons = request.getParameter("cons");
String empId = request.getParameter("emp_id");
String cedula = request.getParameter("cedula");
String apellido = request.getParameter("apellido");
String nombre = request.getParameter("nombre");
String userName = request.getParameter("user_name");
String userId = request.getParameter("user_id");
String parentMode = request.getParameter("parent_mode")==null?"":request.getParameter("parent_mode");

if(mode == null) mode ="add";
if (empId == null) empId = "";

int idonedidadLastLineNo = 0;

if(request.getParameter("idonedidadLastLineNo") != null) idonedidadLastLineNo = Integer.parseInt(request.getParameter("idonedidadLastLineNo"));

System.out.println("MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM MODE = "+mode);
String sql = "";
if (empId.equals("")) empId = "0";
if (fp == null) fp = "";
if (fg == null) fg = "";
if (userName == null) userName = "";
if (userId == null) userId = "";

if (fp.equalsIgnoreCase("user") && empId.trim().equals("0")) empId = userId;

if (request.getMethod().equalsIgnoreCase("GET")){

    if (change == null){
        if (!fp.equalsIgnoreCase("user"))
          sql = "select i.codigo, i.idoneidad, i.folio, i.registro, i.observacion, e.nombre_empleado, e.cedula1, e.num_empleado, e.rata_hora, e.salario_base, to_char(e.fecha_ingreso, 'dd/mm/yyyy') fi, 'prima' prima, i.compania from tbl_pla_idoneidad i, vw_pla_empleado e where e.emp_id = i.emp_id and e.emp_id = "+empId+" and e.compania = "+compania+" and e.compania = i.compania and i.tipo = 'E'";
         else 
           sql = "select i.codigo, i.idoneidad, i.folio, i.registro, i.observacion, i.compania from tbl_pla_idoneidad i where i.emp_id = "+empId+" and i.compania = 1 and i.tipo = 'U'";
           
        al  = SQLMgr.getDataList(sql);
    }
    
    if (al.size() > 0) mode = "edit";
    
    if (parentMode.equals("view")) viewMode = true;

    if (mode.equalsIgnoreCase("add")){
      if (change == null){
        htIdoneidad.clear();
        vIdoneidad.clear();
      }
    }
    else{
        if (change == null ){
            htIdoneidad.clear();
            vIdoneidad.clear();
            
            idonedidadLastLineNo = al.size();
            for (int i=0; i<al.size(); i++){
                idonedidadLastLineNo++;
                if (idonedidadLastLineNo < 10) key = "00" + idonedidadLastLineNo;
                else if (idonedidadLastLineNo < 100) key = "0" + idonedidadLastLineNo;
                else key = "" + idonedidadLastLineNo;
                htIdoneidad.put(key, al.get(i));
            }
        }
    }
%>

<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>

<script>
  function doAction(){}
  function printIdoneidad() {
    abrir_ventana('../admin/print_user_idoneidades.jsp?user_id=<%=empId%>');
  }
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<table width="100%" cellpadding="0" cellspacing="1">
									<%fb = new FormBean("form10",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
									<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
									<%=fb.formStart(true)%>
									<%=fb.hidden("mode",mode)%>
									<%=fb.hidden("tab","10")%>
									<%=fb.hidden("prov",prov)%>
									<%=fb.hidden("sig",sig)%>
									<%=fb.hidden("tom",tom)%>
									<%=fb.hidden("asi",asi)%>
									<%=fb.hidden("emp_id",empId)%>
									<%=fb.hidden("baction","")%>
									<%=fb.hidden("idonedidadLastLineNo",""+idonedidadLastLineNo)%>
									<%=fb.hidden("idoneidadSize",""+htIdoneidad.size())%>
									<%=fb.hidden("fg",fg)%>
									<%=fb.hidden("fp",fp)%>
									<%=fb.hidden("nombre",nombre)%>
									<%=fb.hidden("apellido",apellido)%>
									<%=fb.hidden("cedula",cedula)%>
									<%=fb.hidden("user_name",userName)%>
									<%=fb.hidden("user_id",userId)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(80)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;<%if(fp.equalsIgnoreCase("user")){%>Registro de Usuario<%} else {%>Registro de Empleado<%}%></td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus80" style="display:none">+</label><label id="minus80">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel80">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right"><%if(fp.equalsIgnoreCase("user")){%>Usuario<%} else {%>Empleado<%}%></td>
													<td width="15%">&nbsp;<%=fp.equalsIgnoreCase("user")?userName:cedula%></td>
													<td width="15%" align="right">Nombre</td>
													<td width="55%">&nbsp;<%=fp.equalsIgnoreCase("user")?"":apellido+",&nbsp;"%><%=nombre%></td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(81)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Idoneidad</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus81" style="display:none">+</label><label id="minus81">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel81">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextHeader" align="center">
													<td width="5%">Cod.</td>
													<td width="30%">Idoneidad</td>
													<td width="15%">Registro</td>
													<td width="15%">Folio</td>
													<td width="30%">Observaci&oacute;n</td>
													<td width="5%" align="center"><%=fb.submit("btnagrega","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
												</tr>
												<%
													al=CmnMgr.reverseRecords(htIdoneidad);
													for (int i=0; i<htIdoneidad.size(); i++)
													{
													key = al.get(i).toString();
													CommonDataObject cdo = (CommonDataObject) htIdoneidad.get(key);
												%>
												<%=fb.hidden("key"+i,key)%> <%=fb.hidden("remove"+i,"")%>
												<tr class="TextRow01" align="center">
													<td><%=fb.intBox("codigo"+i,cdo.getColValue("codigo"),false,false,true,2,2,"Text10",null,null)%></td>
													<td align="left"><%=fb.textBox("idoneidad"+i,cdo.getColValue("idoneidad"),true,false,viewMode,60,255,"Text10",null,null)%></td>
													<td>
														<%=fb.textBox("registro"+i,cdo.getColValue("registro"),true,false,viewMode,30,50,"Text10",null,null)%>
													</td>
													<td><%=fb.textBox("folio"+i,cdo.getColValue("folio"),true,false,viewMode,30,50,"Text10",null,null)%></td>
													<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,40,2,500)%></td>
													<td>
													<%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Idoneidad")%>
													</td>
												</tr>
												<%  } 	%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right">
										<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
										<%if(fp.equalsIgnoreCase("user")){%>
                      <%=fb.button("print","Imprimir",true,false,null,null,"onClick=\"javascript:printIdoneidad()\"")%>
										<%}%>
										<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
										</td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
                            </body>
</html>                            
                                
<%
}else{

if(tab.equals("10")){
        String itemRemoved = "";
        String baction = request.getParameter("baction");
		
        ArrayList list = new ArrayList();
		int idoneidadSize = Integer.parseInt(request.getParameter("idoneidadSize"));
		for (int i=0; i<idoneidadSize; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_idoneidad");
			cdo.setWhereClause("emp_id="+empId+" and compania = "+compania);
            
			cdo.addColValue("emp_id",empId);
			cdo.addColValue("compania",compania);
			cdo.addColValue("codigo",request.getParameter("codigo"+i));
			cdo.addColValue("folio",request.getParameter("folio"+i));
			cdo.addColValue("idoneidad",request.getParameter("idoneidad"+i));
			cdo.addColValue("observacion",request.getParameter("observacion"+i));
			cdo.addColValue("registro",request.getParameter("registro"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
            //cdo.setAutoIncWhereClause("emp_id="+empId);
            
      if (fp.equalsIgnoreCase("user")) cdo.addColValue("tipo", "U");      
            
			cdo.setAutoIncCol("codigo");
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try{
					htIdoneidad.put(cdo.getColValue("key"),cdo);
					list.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}//End For
		if(!itemRemoved.equals("")){
			htIdoneidad.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=10&mode="+mode+"&emp_id="+empId+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&idonedidadLastLineNo="+idonedidadLastLineNo+"&fg="+fg+"&fp="+fp+"&nombre="+nombre+"&cedula="+cedula+"&apellido="+apellido);
			return;
		}
		if(baction.equals("+")){
            
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("folio","");
			cdo.addColValue("idoneidad","");
			cdo.addColValue("observacion","");
			cdo.addColValue("registro","");
			cdo.addColValue("codigo","0");
			idonedidadLastLineNo++;
            System.out.println("-------------------------------------------- idonedidadLastLineNo = "+idonedidadLastLineNo);
			if(idonedidadLastLineNo < 10) key = "00" + idonedidadLastLineNo;
			else if(idonedidadLastLineNo <100) key = "0" +idonedidadLastLineNo;
			else key = "" + idonedidadLastLineNo;
			cdo.addColValue("key",key);
			htIdoneidad.put(key,cdo);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=10&mode="+mode+"&emp_id="+empId+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&idonedidadLastLineNo="+idonedidadLastLineNo+"&fg="+fg+"&fp="+fp+"&nombre="+nombre+"&cedula="+cedula+"&apellido="+apellido+"&user_id="+userId+"&user_name="+userName);
			return;
		}//End
		if (baction.equalsIgnoreCase("Guardar")){
			if(al.size() == 0){
				CommonDataObject cdo = new CommonDataObject();
				cdo.setTableName("tbl_pla_idoneidad");
				cdo.setWhereClause("emp_id="+empId);
				list.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.insertList(list);
			ConMgr.clearAppCtx(null);
		}
	}//End tab8
%>
<html>
<head>
<script>
function closeWindow(){
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '../rhplanilla/empleado_idoneidad.jsp?fp=<%=fp%>&fg=<%=fg%>&cedula=<%=cedula%>&nombre=<%=nombre%>&apellido=<%=apellido%>&emp_id=<%=empId%>&mode=edit&user_id=<%=userId%>&user_name=<%=userName%>';
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