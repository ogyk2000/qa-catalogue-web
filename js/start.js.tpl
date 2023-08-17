const obj = JSON.parse("{$fields|escape:javascript}");
const shelf_ready_data = JSON.parse("{$shelf_ready_completeness|escape:javascript}");

const issuesGraphContext = document.getElementById('issuesGraph');
new Chart(issuesGraphContext, {
    type: 'doughnut',
    data: {
        labels: ['Without issues', 'With undefined fields', 'With issues'],
        datasets: [{
            label: '# of Records',
            data: ['{$issueStats->summary->good|escape:javascript}', '{$issueStats->summary->unclear|escape:javascript}', '{$issueStats->summary->bad|escape:javascript}'],
            backgroundColor: ["#37ba00", "#FFFF00", "#FF4136"],
            borderWidth: 1
        }]
    },
    options: {
      responsive: true
    }
});

const authoritiesNameGraphContext = document.getElementById('authoritiesNameGraph');
new Chart(authoritiesNameGraphContext, {
    type: 'doughnut',
    data: {
        labels: ['Without authority name', 'With authority name'],
        datasets: [{
            label: '# of Records',
            data: ['{$authorities->withClassification->count|escape:javascript}', '{$authorities->withoutClassification->count|escape:javascript}'],
            backgroundColor: ["#37ba00", "#FF4136"],
            borderWidth: 1
        }]
    },
    options: {
      responsive: true
    }
});

const authoritiesGraphContext = document.getElementById('authoritiesGraph');
new Chart(authoritiesGraphContext, {
    type: 'doughnut',
    data: {
        labels: ['Without authorities', 'With authorities'],
        datasets: [{
            label: '# of Records',
            data: ['{$classifications->withClassification->count|escape:javascript}', '{$classifications->withoutClassification->count|escape:javascript}'],
            backgroundColor: ["#37ba00", "#FF4136"],
            borderWidth: 1
        }]
    },
    options: {
      responsive: true
    }
});


const completensGraphContext = document.getElementById('completenessGraph');

var completeness = new Chart(completensGraphContext, {
  type: 'bar',
  data: {
    datasets: [
      {
        label: '# of records',
        key: 'Completeness',
        borderColor: 'green',
        backgroundColor: '#37ba00',
        borderWidth: 1,
        spacing: 0
      }
    ],
  },
  options: {
    plugins: {
      legend: {
        display: false
      }
    },
    scales: {
      x: {
        display: false
      }
    },
    onClick: onCompletenessClicked,
    responsive: true,
    aspectRatio: 1,
    parsing: {
      xAxisKey: 'label',
      yAxisKey: 'Completeness'
    }
  }
});

updateCompletenessContent(0, "", "");

document.getElementById("completenessBack").addEventListener('click', onCompletenessBack);


function onCompletenessClicked(event, array) {
  const level = array[0].element.$context.raw.level;
  const packageName = array[0].element.$context.raw.packageName;
  const label = array[0].element.$context.raw.label;

  if (level < 2 && level >= 0) {
    updateCompletenessContent(level + 1, packageName, label);
  }
}

function onCompletenessBack() {
  const level = completeness.data.datasets[0].data[0].level
  const packageName = completeness.data.datasets[0].data[0].packageName

  if (level <= 2 && level > 0) {
    updateCompletenessContent(level - 1, packageName, "");
  }
}

function updateCompletenessContent(level, packageName, label) {

  var tree = null;

  switch(level) {
    case 0:
      tree = Object.entries(obj).map(function(entry) {
              return {
                label: entry[0],
                packageName: entry[0],
                level: 0,
                Completeness: entry[1][""][""].count
              }
            });
    break;

    case 1:
      
      tree = Object.entries(obj[packageName]).filter(function(entry) { // Remove summary entries
              return entry[0] !== "";
            }).map(function(entry) {
              return {
                label: entry[0],
                packageName: packageName,
                level: 1,
                Completeness: entry[1][""].count
              }
            })
    break;

    case 2:
      tree = Object.entries(obj[packageName][label]).filter(function(entry) { // Remove summary entries
              return entry[0] !== "";
            }).map(function(entry) {
              return {
                label: entry[0],
                packageName: packageName,
                level: 2,
                Completeness: Number(entry[1].count),
              }
            });
    break;
  }

  tree.sort(
    function(a, b){
      return b.Completeness - a.Completeness
      });
  completeness.data.datasets[0].data = tree;
  completeness.update();
}

var boothShelfReadyContext = document.getElementById("boothShelfReady");
{literal}
const boothShelfReadyData = Object.keys(shelf_ready_data).map((i) => ({x: i, y: shelf_ready_data[i]}));
{/literal}
var previous_ticks = {$shelf_ready_min};
var previous_tooltip = {$shelf_ready_min};
var boothShelfReadyChart = new Chart(boothShelfReadyContext, {
  type: 'bar',
  data: {
      datasets: [{
          label: 'Records',
          data: boothShelfReadyData,
          backgroundColor: '#37ba00',
          borderWidth: 1,
          barPercentage: 1,
          categoryPercentage: 1
      }]
  },
  options: {
    scales: {
      x: {
        type: 'linear',
        ticks: {
          stepSize: 1,
          callback: (i,a) => {
            const retval = previous_ticks + ' - ' + i;
            previous_ticks++;
            return retval;
          }
        },
        offset: true,
        grid: {
        	display: false
        },
        border: {
          color: 'blue'
        }
      }
    },
    plugins: {
      legend: {
        display: false,
      }
    },
    aspectRatio: 1
  }
});
