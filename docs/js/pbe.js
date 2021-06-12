var sortParameter = null;
var sortDirection = 1;

async function getDomains(){
  const response = await fetch('data/domains.json');
  const data = await response.json();
  return Object.values(data);
}

async function renderDomains(){
  const domains = await getDomains();
  const tbody = document.querySelector("tbody");
  tbody.innerHTML = '';

  const filters = getFilters();

  const filtered = domains
    .filter(filters.price)
    .filter(filters.renewal)
    .filter(filters.transfer)
    .filter(filters.domain);

  let sorted = filtered.sort(sortDomains);

  sorted.forEach(domain => {
    let r = generateRow(domain);
    tbody.appendChild(r)
  })
}


function getFilters(){
  price     = [parseInt(price_min.value),     parseInt(price_max.value)]
  renewal   = [parseInt(renewal_min.value),   parseInt(renewal_max.value)]
  transfer  = [parseInt(transfer_min.value),  parseInt(transfer_max.value)]
  domain    = domain_name.value || "";

  return {
    price: generateFilter("price", price),
    renewal: generateFilter("renewal", renewal),
    transfer: generateFilter("transfer", transfer),
    domain: generateTextFilter(domain)
  }
}

function generateFilter(key, bounds){
  return function(entry){
    let data = entry[key].cost;
    if (isNaN(bounds[0]) && isNaN(bounds[1])){ return true };

    let lower = !isNaN(bounds[0]) ? data > bounds[0] : true;
    let upper = !isNaN(bounds[1]) ? data < bounds[1] : true;

    return lower && upper;
  }
}

function generateTextFilter(substr){
  return function(entry){
    if (substr == undefined || substr.length == 0){ return true };
    return entry.domain.match(substr) != undefined;
  }
}

function sortDomains(a, b){
  if (!sortParameter){ return true }
  let s = 0;
  if (sortParameter != "domain"){
    s = a[sortParameter].cost - b[sortParameter].cost;
  } else {
    s = a[sortParameter] > b[sortParameter];
  }

  return (s * sortDirection);
}


function generateRow(domain){
  let r = document.createElement("tr");
  r.innerHTML = `
    <td><a href="https://porkbun.com/tld/${domain.domain.slice(1)}" target="_blank">${domain.domain}</a></td>
    <td>$${domain.price.cost}</td>
    <td>$${domain.renewal.cost}</td>
    <td>$${domain.transfer.cost}</td>
  `

  return r;
}

function updateSort(e){
  sortParameter = e.target.dataset.f;
  sortDirection = sortDirection * -1;
  renderDomains();
}


function clearSearch(e){
  e.target.parentNode.querySelectorAll("input").forEach( e => {
    e.value = "";
  })
  renderDomains();
}


[price_min, price_max, renewal_min, renewal_max, transfer_min, transfer_max, domain_name].forEach( e => {
  e.addEventListener("keyup", renderDomains);
})

document.querySelectorAll("i.clear").forEach( e => {
  e.addEventListener("click", clearSearch)
})

document.querySelectorAll("th[id*='sort']").forEach( e => {
  e.addEventListener("click", updateSort);
})



document.addEventListener("DOMContentLoaded", function(e){
  (async() => {
    renderDomains();
  })();
});
