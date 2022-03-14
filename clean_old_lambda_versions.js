const AWS = require("aws-sdk");
AWS.config.update({
	region: process.argv[4],
});
const lambda = new AWS.Lambda();
exports.handler = async () => {
	try {
		const FunctionName = process.argv[2];
		const versions_to_keep = Number(process.argv[3]);
		let Marker = null;
		let all_functions = [];
		do {
			const {Functions, NextMarker} = await lambda
				.listFunctions({
					FunctionVersion: "ALL",
					Marker,
					MaxItems: 50,
				})
				.promise();
			Marker = NextMarker;
			all_functions.push(
				...Functions.filter(
					(x) =>
						x.FunctionName === FunctionName &&
						x.Version != "$LATEST"
				)
			);
		} while (Marker != null);

		if (all_functions.length < versions_to_keep) {
			return;
		}

		let lambdas = all_functions.sort(
			(a, b) =>
				(a.Version > b.Version) - (a.Version < b.Version)
		);

		for (
			let index = 0;
			index < lambdas.length - versions_to_keep;
			index++
		) {
			await lambda
				.deleteFunction({
					FunctionName,
					Qualifier: lambdas[index].Version,
				})
				.promise();
			console.log(
				`${FunctionName}:${lambdas[index].Version} deleted`
			);
		}
	} catch (error) {
		console.error(error);
	}
};

this.handler();
