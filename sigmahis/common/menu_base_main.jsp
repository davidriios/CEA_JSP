<script language="javascript">
function goUp(){var lm=0;if(window.frames['MenuItems'])lm=window.frames['MenuItems'].getLM();setFrameSrc('MenuItems','<%=request.getContextPath()%>/common/menuitems.jsp?cm='+lm);}
function goMain(){setFrameSrc('MenuItems','<%=request.getContextPath()%>/common/menuitems.jsp?cm=0');}
function setContent(src){var frameObject=parent.document.getElementById("content");frameObject.src=src;}
var sdt='<%=CmnMgr.getCurrentDate("yyyy:mm:dd:hh24:mi:ss")%>'.split(':');
var tLocal=new Date();
var tServer=new Date(sdt[0],(sdt[1]-1),sdt[2],sdt[3],sdt[4],sdt[5],0);
var tDiff=tLocal-tServer;
const options = { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second:'2-digit', timeZone: 'America/Panama', hour12: false };
window.onload=function(){clockTimer();initialFunctionInvokedAfterLoadingMain();setInterval("clockTimer()",1000);}
function clockTimer(){var ct=new Date();ct.setMilliseconds(ct.getMilliseconds()-tDiff);
/*DATE/TIME BASED ON LOCAL *///document.getElementById("dateTimeObj").innerHTML=ct.toLocaleDateString('es-US', options);
/*DATE/TIME BASED ON SERVER*/document.getElementById("dateTimeObj").innerHTML=((ct.getDate()<10)?'0':'')+ct.getDate()+'/'+(((ct.getMonth()+1)<10)?'0':'')+(ct.getMonth()+1)+'/'+ct.getFullYear()+' '+((ct.getHours()<10)?'0':'')+ct.getHours()+':'+((ct.getMinutes()<10)?'0':'')+ct.getMinutes()+':'+((ct.getSeconds()<10)?'0':'')+ct.getSeconds();
}
</script>
<table width="100%" cellpadding="0" cellspacing="0" border="0" style=" border-bottom:1.0pt solid #CCCCCC;" id="_tblMainHeader">
<tr>
	<td height="55" width="190" align="center">
	    <img
	        id="_companyLogo"
	        src="<%=request.getContextPath()%>/<%=(String) session.getAttribute("_appCompLogoFile")%>"
	        alt="Sigma HIS"
	        name="_companyLogo"
	        width="160"
	        height="57"
	        border="0"
	        onclick="javascript:toggleMenu()"
	        style="margin-top: 10px;margin-bottom: 10px;"
	        id="_companyLogo"/>
	</td>
	<td height="55">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td width="100%" style="border-bottom:1.0pt solid #FFFFFF;">
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<!--<td width="108"><a href="#" onMouseover="scrollspeed=-3" onMouseout="scrollspeed=0"><img src="<%=request.getContextPath()%>/images/aleft.gif" border="0" alt="Scroll Left"/></a><a href="#" onMouseover="scrollspeed=3" onMouseout="scrollspeed=0"><img src="<%=request.getContextPath()%>/images/aright.gif" border="0" alt="Scroll Right"/></a><a href="javascript:goUp()"><img src="<%=request.getContextPath()%>/images/uplevel.gif" border="0" alt="Up Level"/></a><a href="javascript:goMain()"><img src="<%=request.getContextPath()%>/images/hsi.gif" border="0" alt="Main Menu"/></a></td>
					-->
					<td align="center">
					<!-- this iFrame is meant to hold the old-menu items -->
					<!--
					<iframe id="MenuItems" name="MenuItems" scrolling="auto" frameborder="0" marginheight="0" marginwidth="0" width="100%" height="40px" allowtransparency src="<%=request.getContextPath()%>/common/menuitems.jsp"></iframe>
					</td>
					-->
				</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="25">
				<table width="100%" cellpadding="3" cellspacing="0" border="0">
				<tr class="MenuUserDetails">
					<td align="left" width="10">
					    <!-- this link used to be for the old-menu, to go to the root items of that menu -->
					    <!--
					    <a href="javascript:goMain();">
					        <img src="<%=request.getContextPath()%>/images/home.png" border="0" alt="Home" align="absmiddle"/>
					    </a>
					     -->
					</td>
					<td align="left" >
					    <a href="javascript:toggleMenu()">
                              <h7 id="topMenuCurrentLocationLabel"
                                  style="padding-left: 21px;background-color: #FFFFFF;"
                                  class="TextModuleName" ></h7>
                        </a>
					</td>
					<td width="24"><img src="<%=request.getContextPath()%>/images/user.png" border="0" alt="User @ IP Address" align="absmiddle"<%=(UserDet.getUserProfile().contains("0"))?" onDblClick=\"javascript:ajaxHandler('"+request.getContextPath()+"/admin/app_users_details.jsp','id="+UserDet.getUserId()+"&user="+UserDet.getUserName()+"&u','POST');\"":""%>/></td>
					<td width="200" align="left"><%=(session.getAttribute("_userCompleteName") != null && session.getAttribute("_userName") != null)?session.getAttribute("_userName")+" ["+session.getAttribute("_userCompleteName")+"] @ "+request.getRemoteHost():""%></td>
					<td width="24"><img src="<%=request.getContextPath()%>/images/clock_main.png" border="0" alt="Date / Time" align="absmiddle"/></td>
					<td width="85"><span id="dateTimeObj"></span><%//=CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")%></td>
					<td width="80" align="left"><!--<a href="javascript:parent.resetContentHeight();setContent('')"><img src="<%=request.getContextPath()%>/images/home.gif" border="0" alt="Home" align="absmiddle"/></a>-->
					<a href="javascript:abrir_ventana('<%=request.getContextPath()%>/admin/user_preferences.jsp')"><img src="<%=request.getContextPath()%>/images/options.png" border="0" alt="Preferences" align="absmiddle"/></a>
					<a href="<%=request.getContextPath()%>/logout.jsp"><img src="<%=request.getContextPath()%>/images/signout.png" border="0" alt="Logout" align="absmiddle"/></a></td>
				</tr>
				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
