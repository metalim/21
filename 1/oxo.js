// Generated by CoffeeScript 1.6.3
/* (c) 2013 Maxim Litvinov*/(function(){var e=[].indexOf||function(e){for(var t=0,n=this.length;t<n;t++)if(t in this&&this[t]===e)return t;return-1};$(function(){var t,n,r,i,s,o,u,a=document.getElementById("canvas"),f=a.getContext("2d"),l=n=i=o=u=null,c=r=[[null,null,null],[null,null,null],[null,null,null]],h=9,p=1,d=function(){var e,t,n,r,s,a;for(n=r=0,a=c.length;r<a;n=++r){e=c[n];if(e[0]!=null&&e[0]===e[1]&&e[1]===e[2]){p=null;f.strokeStyle="red";f.beginPath();f.moveTo(o,u+i/6+i/3*n);f.lineTo(o+i,u+i/6+i/3*n);f.stroke()}}for(t=s=0;s<=2;t=++s)if(c[0][t]!=null&&c[0][t]===c[1][t]&&c[1][t]===c[2][t]){p=null;f.strokeStyle="red";f.beginPath();f.moveTo(o+i/6+i/3*t,u);f.lineTo(o+i/6+i/3*t,u+i);f.stroke()}if(c[0][0]!=null&&c[0][0]===c[1][1]&&c[1][1]===c[2][2]){p=null;f.strokeStyle="red";f.beginPath();f.moveTo(o,u);f.lineTo(o+i,u+i);f.stroke()}if(c[2][0]!=null&&c[2][0]===c[1][1]&&c[1][1]===c[0][2]){p=null;f.strokeStyle="red";f.beginPath();f.moveTo(o+i,u);f.lineTo(o,u+i);return f.stroke()}},v=function(){var e,t,r,s,a,h,p,v;f.clearRect(0,0,l,n);f.lineWidth=10;f.lineCap="round";f.strokeStyle="#000";f.beginPath();f.moveTo(o+i/3,u);f.lineTo(o+i/3,u+i);f.moveTo(o+2*i/3,u);f.lineTo(o+2*i/3,u+i);f.moveTo(o,u+i/3);f.lineTo(o+i,u+i/3);f.moveTo(o,u+2*i/3);f.lineTo(o+i,u+2*i/3);f.stroke();for(s=a=0,p=c.length;a<p;s=++a){t=c[s];for(r=h=0,v=t.length;h<v;r=++h){e=t[r];if(e!=null)if(e===0){f.beginPath();f.arc(o+r*i/3+i/6,u+s*i/3+i/6,i/9,0,Math.PI*2,0);f.stroke()}else if(e===1){f.beginPath();f.moveTo(o+r*i/3+i/20,u+s*i/3+i/20);f.lineTo(o+r*i/3+i/3-i/20,u+s*i/3+i/3-i/20);f.moveTo(o+r*i/3+i/20,u+s*i/3+i/3-i/20);f.lineTo(o+r*i/3+i/3-i/20,u+s*i/3+i/20);f.stroke()}}}return d()};window.onresize=s=function(){l=a.width=a.offsetWidth;n=a.height=a.offsetHeight;i=l<n?l-20:n-20;o=(l-i)/2;u=(n-i)/2;return v()};s();return a.onclick=t=function(t){var n,r,s;if(!(p!=null&&h>0)){c=[[null,null,null],[null,null,null],[null,null,null]];p=1;h=9;return v()}n=$(a).offset();r=Math.floor((t.pageX-n.left-o)/i*3);s=Math.floor((t.pageY-n.top-u)/i*3);console.log(r,s);if(e.call([0,1,2],r)>=0&&e.call([0,1,2],s)>=0&&c[s][r]==null){c[s][r]=p;h-=1;p=1-p;return v()}}})}).call(this);